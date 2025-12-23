export type User = {
  id: string;
  email: string;
};

export type JwtTokenResponse = {
  accessToken: string;
  refreshToken: string;
};

export type AuthResponse = JwtTokenResponse & User;
