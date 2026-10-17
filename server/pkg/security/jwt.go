package security

import (
	"crypto/subtle"
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

const (
	claimSubject   = "sub"
	claimEmail     = "email"
	claimType      = "type"
	claimIssuedAt  = "iat"
	claimExpiresAt = "exp"
)

var (
	ErrUnexpectedSigningMethod = errors.New("unexpected signing method")
	ErrInvalidToken            = errors.New("invalid token")
	ErrInvalidTokenClaims      = errors.New("invalid token claims")
	ErrMissingSubjectClaim     = errors.New("missing sub claim")
	ErrInvalidSubjectFormat    = errors.New("invalid sub format")
)

type JwtUser struct {
	ID    uuid.UUID
	Email string
}

type TokenProvider struct {
	secretKey              []byte
	accessTokenExpiration  time.Duration
	refreshTokenExpiration time.Duration
	reviewerKey            string
}

func NewTokenProvider(secretKey string, accessExp, refreshExp time.Duration, reviewerKey string) *TokenProvider {
	if accessExp == 0 {
		accessExp = 15 * time.Minute
	}
	if refreshExp == 0 {
		refreshExp = 14 * 24 * time.Hour
	}
	return &TokenProvider{
		secretKey:              []byte(secretKey),
		accessTokenExpiration:  accessExp,
		refreshTokenExpiration: refreshExp,
		reviewerKey:            reviewerKey,
	}
}

func (p *TokenProvider) GenerateAccessToken(user JwtUser) (string, error) {
	return p.generateToken(user, p.accessTokenExpiration, types.TokenTypeAccess)
}

func (p *TokenProvider) GenerateRefreshToken(user JwtUser) (string, error) {
	return p.generateToken(user, p.refreshTokenExpiration, types.TokenTypeRefresh)
}

// GenerateTokenPair generates both an access token and a refresh token for the given user.
func (p *TokenProvider) GenerateTokenPair(user JwtUser) (accessToken, refreshToken string, err error) {
	accessToken, err = p.GenerateAccessToken(user)
	if err != nil {
		return "", "", err
	}
	refreshToken, err = p.GenerateRefreshToken(user)
	if err != nil {
		return "", "", err
	}
	return accessToken, refreshToken, nil
}

func (p *TokenProvider) generateToken(user JwtUser, exp time.Duration, tokenType string) (string, error) {
	now := time.Now().UTC()
	claims := jwt.MapClaims{
		claimSubject:   user.ID.String(),
		claimEmail:     user.Email,
		claimType:      tokenType,
		claimIssuedAt:  now.Unix(),
		claimExpiresAt: now.Add(exp).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(p.secretKey)
}

func (p *TokenProvider) ExtractUser(tokenStr string) (JwtUser, error) {
	token, err := jwt.Parse(tokenStr, func(token *jwt.Token) (any, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrUnexpectedSigningMethod
		}
		return p.secretKey, nil
	})
	if err != nil || !token.Valid {
		return JwtUser{}, ErrInvalidToken
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return JwtUser{}, ErrInvalidTokenClaims
	}

	subStr, ok := claims[claimSubject].(string)
	if !ok {
		return JwtUser{}, ErrMissingSubjectClaim
	}
	id, err := uuid.Parse(subStr)
	if err != nil {
		return JwtUser{}, ErrInvalidSubjectFormat
	}

	email, _ := claims[claimEmail].(string)
	return JwtUser{
		ID:    id,
		Email: email,
	}, nil
}

func (p *TokenProvider) IsTokenValid(tokenStr string, expectedType string) bool {
	token, err := jwt.Parse(tokenStr, func(token *jwt.Token) (any, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrUnexpectedSigningMethod
		}
		return p.secretKey, nil
	})
	if err != nil || !token.Valid {
		return false
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return false
	}

	tokenType, ok := claims[claimType].(string)
	if !ok || tokenType != expectedType {
		return false
	}

	return true
}

func (p *TokenProvider) ValidateReviewerKey(reviewerKey string) bool {
	if p.reviewerKey == "" || reviewerKey == "" {
		return false
	}
	return subtle.ConstantTimeCompare([]byte(reviewerKey), []byte(p.reviewerKey)) == 1
}
