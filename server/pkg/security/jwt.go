package security

import (
	"crypto/subtle"
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
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
	return p.generateToken(user, p.accessTokenExpiration, "ACCESS")
}

func (p *TokenProvider) GenerateRefreshToken(user JwtUser) (string, error) {
	return p.generateToken(user, p.refreshTokenExpiration, "REFRESH")
}

func (p *TokenProvider) generateToken(user JwtUser, exp time.Duration, tokenType string) (string, error) {
	now := time.Now().UTC()
	claims := jwt.MapClaims{
		"sub":   user.ID.String(),
		"email": user.Email,
		"type":  tokenType,
		"iat":   now.Unix(),
		"exp":   now.Add(exp).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(p.secretKey)
}

func (p *TokenProvider) ExtractUser(tokenStr string) (JwtUser, error) {
	token, err := jwt.Parse(tokenStr, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return p.secretKey, nil
	})
	if err != nil || !token.Valid {
		return JwtUser{}, errors.New("invalid token")
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return JwtUser{}, errors.New("invalid token claims")
	}

	subStr, ok := claims["sub"].(string)
	if !ok {
		return JwtUser{}, errors.New("missing sub")
	}
	id, err := uuid.Parse(subStr)
	if err != nil {
		return JwtUser{}, errors.New("invalid sub format")
	}

	email, _ := claims["email"].(string)
	return JwtUser{
		ID:    id,
		Email: email,
	}, nil
}

func (p *TokenProvider) IsTokenValid(tokenStr string, expectedType string) bool {
	token, err := jwt.Parse(tokenStr, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
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

	tType, ok := claims["type"].(string)
	if !ok || tType != expectedType {
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
