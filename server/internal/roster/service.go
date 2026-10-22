package roster

import (
	"context"
	"database/sql"
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/logger"
	"github.com/krivolapovdev/trenerio/internal/shared/request"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/shared/types"
	"github.com/krivolapovdev/trenerio/internal/shared/utils"
	"github.com/krivolapovdev/trenerio/internal/shared/validator"
)

type StudentProvider interface {
	GetStudentsByIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]response.StudentResponse, error)
}

type Service struct {
	db              *db.Queries
	sqlDB           *sql.DB
	studentProvider StudentProvider
}

func NewService(queries *db.Queries, sqlDB *sql.DB, studentProvider StudentProvider) *Service {
	return &Service{
		db:              queries,
		sqlDB:           sqlDB,
		studentProvider: studentProvider,
	}
}

func (s *Service) withTx(ctx context.Context, fn func(qtx *db.Queries) error) error {
	if s.sqlDB == nil {
		return fn(s.db)
	}
	return db.WithTx(ctx, s.sqlDB, s.db, fn)
}

func (s *Service) GetAllRosters(ctx context.Context, ownerID uuid.UUID) ([]response.RosterResponse, error) {
	logger.InfoContext(ctx, "Getting all rosters", "user_id", ownerID.String())
	rosterRows, err := s.db.FindAllRostersByOwnerID(ctx, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get all rosters", "error", err, "user_id", ownerID.String())
		return nil, err
	}
	if len(rosterRows) == 0 {
		logger.InfoContext(ctx, "No rosters found", "user_id", ownerID.String())
		return []response.RosterResponse{}, nil
	}

	rosterIDs := make([]uuid.UUID, 0, len(rosterRows))
	for _, r := range rosterRows {
		rosterIDs = append(rosterIDs, r.ID)
	}

	counts, err := s.db.CountParticipantsByRosterIDs(ctx, db.CountParticipantsByRosterIDsParams{
		OwnerID: ownerID,
		Column2: rosterIDs,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to count participants by roster IDs", "error", err, "user_id", ownerID.String())
		return nil, err
	}

	countMap := make(map[uuid.UUID]int64, len(counts))
	for _, c := range counts {
		countMap[c.RosterID] = c.StudentCount
	}

	res := make([]response.RosterResponse, 0, len(rosterRows))
	for _, r := range rosterRows {
		res = append(res, toRosterResponse(r, countMap[r.ID], nil))
	}

	logger.InfoContext(ctx, "Retrieved all rosters", "count", len(res), "user_id", ownerID.String())
	return res, nil
}

func (s *Service) GetRosterByID(ctx context.Context, rosterID, ownerID uuid.UUID) (response.RosterResponse, error) {
	logger.InfoContext(ctx, "Getting roster by id", "roster_id", rosterID.String(), "user_id", ownerID.String())
	r, err := s.db.FindRosterByIDAndOwnerID(ctx, db.FindRosterByIDAndOwnerIDParams{
		ID:      rosterID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Roster not found", "roster_id", rosterID.String(), "user_id", ownerID.String())
			return response.RosterResponse{}, pkgerrors.NewNotFound("Roster", rosterID, ownerID)
		}
		logger.ErrorContext(ctx, "Failed to get roster by id", "roster_id", rosterID.String(), "error", err, "user_id", ownerID.String())
		return response.RosterResponse{}, err
	}

	students, err := s.getParticipantsForRoster(ctx, rosterID, ownerID)
	if err != nil {
		return response.RosterResponse{}, err
	}

	return toRosterResponse(r, int64(len(students)), students), nil
}

func (s *Service) GetRosterStudents(ctx context.Context, rosterID, ownerID uuid.UUID) ([]response.StudentResponse, error) {
	logger.InfoContext(ctx, "Getting students for roster", "roster_id", rosterID.String(), "user_id", ownerID.String())
	if _, err := s.db.FindRosterByIDAndOwnerID(ctx, db.FindRosterByIDAndOwnerIDParams{
		ID:      rosterID,
		OwnerID: ownerID,
	}); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Roster not found", "roster_id", rosterID.String(), "user_id", ownerID.String())
			return nil, pkgerrors.NewNotFound("Roster", rosterID, ownerID)
		}
		return nil, err
	}

	return s.getParticipantsForRoster(ctx, rosterID, ownerID)
}

func (s *Service) CreateRoster(ctx context.Context, req request.CreateRosterRequest, ownerID uuid.UUID) (response.RosterResponse, error) {
	logger.InfoContext(ctx, "Creating roster", "name", req.Name, "user_id", ownerID.String())
	name, err := validator.ValidateRequiredName(req.Name, "name")
	if err != nil {
		logger.WarnContext(ctx, "Roster name validation failed", "user_id", ownerID.String())
		return response.RosterResponse{}, err
	}

	var uniqueStudentIDs []uuid.UUID
	if len(req.StudentIds) > 0 {
		uniqueStudentIDs = utils.UniqueUUIDs(req.StudentIds)
		if err := s.validateStudentIDsExist(ctx, uniqueStudentIDs, ownerID); err != nil {
			return response.RosterResponse{}, err
		}
	}

	var created db.RostersModuleRoster
	err = s.withTx(ctx, func(qtx *db.Queries) error {
		var rosterDate sql.NullTime
		if req.RosterDate != nil {
			rosterDate = sql.NullTime{Time: *req.RosterDate, Valid: true}
		}

		var note sql.NullString
		if req.Note != nil && strings.TrimSpace(*req.Note) != "" {
			note = sql.NullString{String: strings.TrimSpace(*req.Note), Valid: true}
		}

		var err error
		created, err = qtx.CreateRoster(ctx, db.CreateRosterParams{
			OwnerID:    ownerID,
			Name:       name,
			RosterDate: rosterDate,
			Note:       note,
		})
		if err != nil {
			logger.ErrorContext(ctx, "Failed to create roster record", "name", name, "error", err, "user_id", ownerID.String())
			return err
		}

		for _, sid := range uniqueStudentIDs {
			_, err := qtx.CreateParticipant(ctx, db.CreateParticipantParams{
				RosterID:  created.ID,
				StudentID: sid,
			})
			if err != nil {
				logger.ErrorContext(ctx, "Failed to create participant", "roster_id", created.ID.String(), "student_id", sid.String(), "error", err, "user_id", ownerID.String())
				return err
			}
		}

		return nil
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to create roster in database", "name", name, "error", err, "user_id", ownerID.String())
		return response.RosterResponse{}, err
	}

	var students []response.StudentResponse
	if len(uniqueStudentIDs) > 0 && s.studentProvider != nil {
		stList, err := s.studentProvider.GetStudentsByIDs(ctx, uniqueStudentIDs, ownerID)
		if err == nil {
			students = stList
		}
	}

	logger.InfoContext(ctx, "Roster created successfully", "roster_id", created.ID.String(), "name", created.Name, "user_id", ownerID.String())
	return toRosterResponse(created, int64(len(uniqueStudentIDs)), students), nil
}

func (s *Service) UpdateRoster(ctx context.Context, rosterID, ownerID uuid.UUID, updates map[string]any) (response.RosterResponse, error) {
	logger.InfoContext(ctx, "Updating roster", "roster_id", rosterID.String(), "user_id", ownerID.String())
	var updated db.RostersModuleRoster

	err := s.withTx(ctx, func(qtx *db.Queries) error {
		existing, err := qtx.FindRosterByIDAndOwnerID(ctx, db.FindRosterByIDAndOwnerIDParams{
			ID:      rosterID,
			OwnerID: ownerID,
		})
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				logger.WarnContext(ctx, "Roster to update not found", "roster_id", rosterID.String(), "user_id", ownerID.String())
				return pkgerrors.NewNotFound("Roster", rosterID, ownerID)
			}
			logger.ErrorContext(ctx, "Failed to find roster for update", "roster_id", rosterID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		name := existing.Name
		if rawName, ok := updates["name"]; ok && rawName != nil {
			nameStr, isStr := rawName.(string)
			if !isStr {
				logger.WarnContext(ctx, "Updated roster name must not be blank", "roster_id", rosterID.String(), "user_id", ownerID.String())
				return pkgerrors.NewBadRequest("name must not be blank")
			}
			trimmed, err := validator.ValidateRequiredName(nameStr, "name")
			if err != nil {
				return err
			}
			name = trimmed
		}

		rosterDate := existing.RosterDate
		if rawDate, ok := updates["rosterDate"]; ok {
			if rawDate == nil {
				rosterDate = sql.NullTime{Valid: false}
			} else {
				switch v := rawDate.(type) {
				case time.Time:
					rosterDate = sql.NullTime{Time: v, Valid: true}
				case string:
					t, err := time.Parse(time.RFC3339, v)
					if err != nil {
						logger.WarnContext(ctx, "Invalid rosterDate format for update", "roster_id", rosterID.String(), "user_id", ownerID.String())
						return pkgerrors.NewBadRequest("invalid rosterDate format, expected RFC3339")
					}
					rosterDate = sql.NullTime{Time: t, Valid: true}
				default:
					return pkgerrors.NewBadRequest("invalid rosterDate format")
				}
			}
		}

		note := existing.Note
		if rawNote, ok := updates["note"]; ok {
			if rawNote == nil {
				note = sql.NullString{Valid: false}
			} else if str, ok := rawNote.(string); ok {
				trimmed := strings.TrimSpace(str)
				if trimmed == "" {
					note = sql.NullString{Valid: false}
				} else {
					note = sql.NullString{String: trimmed, Valid: true}
				}
			}
		}

		if rawSIDs, ok := updates["studentIds"]; ok {
			requestedStudentIDs := types.ParseUUIDSlice(rawSIDs)
			if len(requestedStudentIDs) > 0 {
				if err := s.validateStudentIDsExist(ctx, requestedStudentIDs, ownerID); err != nil {
					return err
				}
			}

			currentLinks, err := qtx.FindParticipantsByRosterIDAndOwnerID(ctx, db.FindParticipantsByRosterIDAndOwnerIDParams{
				RosterID: rosterID,
				OwnerID:  ownerID,
			})
			if err != nil {
				logger.ErrorContext(ctx, "Failed to find current participants for update", "roster_id", rosterID.String(), "error", err, "user_id", ownerID.String())
				return err
			}

			currentStudentIDs := make([]uuid.UUID, 0, len(currentLinks))
			for _, cl := range currentLinks {
				currentStudentIDs = append(currentStudentIDs, cl.StudentID)
			}

			toDelete, toCreate := utils.DiffUUIDs(currentStudentIDs, requestedStudentIDs)
			for _, sid := range toDelete {
				if err := qtx.DeleteParticipantByStudentAndRosterID(ctx, db.DeleteParticipantByStudentAndRosterIDParams{
					RosterID:  rosterID,
					StudentID: sid,
				}); err != nil {
					logger.ErrorContext(ctx, "Failed to unlink student during roster update", "roster_id", rosterID.String(), "student_id", sid.String(), "error", err, "user_id", ownerID.String())
					return err
				}
			}

			for _, sid := range toCreate {
				if _, err := qtx.CreateParticipant(ctx, db.CreateParticipantParams{
					RosterID:  rosterID,
					StudentID: sid,
				}); err != nil {
					logger.ErrorContext(ctx, "Failed to link student during roster update", "roster_id", rosterID.String(), "student_id", sid.String(), "error", err, "user_id", ownerID.String())
					return err
				}
			}
		}

		var errUpdate error
		updated, errUpdate = qtx.UpdateRoster(ctx, db.UpdateRosterParams{
			ID:         rosterID,
			OwnerID:    ownerID,
			Name:       name,
			RosterDate: rosterDate,
			Note:       note,
		})
		if errUpdate != nil {
			logger.ErrorContext(ctx, "Failed to update roster record", "roster_id", rosterID.String(), "error", errUpdate, "user_id", ownerID.String())
			return errUpdate
		}

		return nil
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to update roster in database", "roster_id", rosterID.String(), "error", err, "user_id", ownerID.String())
		return response.RosterResponse{}, err
	}

	students, err := s.getParticipantsForRoster(ctx, rosterID, ownerID)
	if err != nil {
		return response.RosterResponse{}, err
	}

	logger.InfoContext(ctx, "Roster updated successfully", "roster_id", updated.ID.String(), "name", updated.Name, "user_id", ownerID.String())
	return toRosterResponse(updated, int64(len(students)), students), nil
}

func (s *Service) DeleteRoster(ctx context.Context, rosterID, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Deleting roster", "roster_id", rosterID.String(), "user_id", ownerID.String())
	_, err := s.db.FindRosterByIDAndOwnerID(ctx, db.FindRosterByIDAndOwnerIDParams{
		ID:      rosterID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Roster to delete not found", "roster_id", rosterID.String(), "user_id", ownerID.String())
			return pkgerrors.NewNotFound("Roster", rosterID, ownerID)
		}
		logger.ErrorContext(ctx, "Failed to find roster for deletion", "roster_id", rosterID.String(), "error", err, "user_id", ownerID.String())
		return err
	}

	if err := s.db.DeleteRosterByIDAndOwnerID(ctx, db.DeleteRosterByIDAndOwnerIDParams{
		ID:      rosterID,
		OwnerID: ownerID,
	}); err != nil {
		logger.ErrorContext(ctx, "Failed to delete roster record", "roster_id", rosterID.String(), "error", err, "user_id", ownerID.String())
		return err
	}

	logger.InfoContext(ctx, "Roster deleted successfully", "roster_id", rosterID.String(), "user_id", ownerID.String())
	return nil
}

func (s *Service) AddStudents(ctx context.Context, rosterID, ownerID uuid.UUID, studentIDs []uuid.UUID) (response.RosterResponse, error) {
	logger.InfoContext(ctx, "Adding students to roster", "roster_id", rosterID.String(), "count", len(studentIDs), "user_id", ownerID.String())
	roster, err := s.db.FindRosterByIDAndOwnerID(ctx, db.FindRosterByIDAndOwnerIDParams{
		ID:      rosterID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return response.RosterResponse{}, pkgerrors.NewNotFound("Roster", rosterID, ownerID)
		}
		return response.RosterResponse{}, err
	}

	uniqueStudentIDs := utils.UniqueUUIDs(studentIDs)
	if len(uniqueStudentIDs) == 0 {
		return s.GetRosterByID(ctx, rosterID, ownerID)
	}

	if err := s.validateStudentIDsExist(ctx, uniqueStudentIDs, ownerID); err != nil {
		return response.RosterResponse{}, err
	}

	err = s.withTx(ctx, func(qtx *db.Queries) error {
		currentLinks, err := qtx.FindParticipantsByRosterIDAndOwnerID(ctx, db.FindParticipantsByRosterIDAndOwnerIDParams{
			RosterID: rosterID,
			OwnerID:  ownerID,
		})
		if err != nil {
			return err
		}

		existingMap := make(map[uuid.UUID]bool, len(currentLinks))
		for _, link := range currentLinks {
			existingMap[link.StudentID] = true
		}

		for _, sid := range uniqueStudentIDs {
			if !existingMap[sid] {
				if _, err := qtx.CreateParticipant(ctx, db.CreateParticipantParams{
					RosterID:  rosterID,
					StudentID: sid,
				}); err != nil {
					return err
				}
			}
		}
		return nil
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to add students to roster", "roster_id", rosterID.String(), "error", err, "user_id", ownerID.String())
		return response.RosterResponse{}, err
	}

	students, err := s.getParticipantsForRoster(ctx, rosterID, ownerID)
	if err != nil {
		return response.RosterResponse{}, err
	}

	return toRosterResponse(roster, int64(len(students)), students), nil
}

func (s *Service) RemoveStudent(ctx context.Context, rosterID, studentID, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Removing student from roster", "roster_id", rosterID.String(), "student_id", studentID.String(), "user_id", ownerID.String())
	if _, err := s.db.FindRosterByIDAndOwnerID(ctx, db.FindRosterByIDAndOwnerIDParams{
		ID:      rosterID,
		OwnerID: ownerID,
	}); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return pkgerrors.NewNotFound("Roster", rosterID, ownerID)
		}
		return err
	}

	exists, err := s.db.ExistsParticipant(ctx, db.ExistsParticipantParams{
		RosterID:  rosterID,
		StudentID: studentID,
	})
	if err != nil {
		return err
	}
	if !exists {
		return pkgerrors.NewNotFound("Participant", studentID, ownerID)
	}

	return s.db.DeleteParticipantByStudentAndRosterID(ctx, db.DeleteParticipantByStudentAndRosterIDParams{
		RosterID:  rosterID,
		StudentID: studentID,
	})
}

func (s *Service) validateStudentIDsExist(ctx context.Context, ids []uuid.UUID, ownerID uuid.UUID) error {
	if s.studentProvider == nil || len(ids) == 0 {
		return nil
	}
	found, err := s.studentProvider.GetStudentsByIDs(ctx, ids, ownerID)
	if err != nil {
		return err
	}
	if len(found) != len(ids) {
		return pkgerrors.NewBadRequest("One or more student IDs not found")
	}
	return nil
}

func (s *Service) getParticipantsForRoster(ctx context.Context, rosterID, ownerID uuid.UUID) ([]response.StudentResponse, error) {
	participantRows, err := s.db.FindParticipantsByRosterIDAndOwnerID(ctx, db.FindParticipantsByRosterIDAndOwnerIDParams{
		RosterID: rosterID,
		OwnerID:  ownerID,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get participants for roster", "roster_id", rosterID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}
	if len(participantRows) == 0 {
		return []response.StudentResponse{}, nil
	}

	studentIDs := make([]uuid.UUID, 0, len(participantRows))
	for _, p := range participantRows {
		studentIDs = append(studentIDs, p.StudentID)
	}

	if s.studentProvider != nil {
		stList, err := s.studentProvider.GetStudentsByIDs(ctx, studentIDs, ownerID)
		if err != nil {
			logger.ErrorContext(ctx, "Failed to fetch student details for roster", "roster_id", rosterID.String(), "error", err, "user_id", ownerID.String())
			return nil, err
		}
		return stList, nil
	}

	return []response.StudentResponse{}, nil
}
