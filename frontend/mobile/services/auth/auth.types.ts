export type JwtTokenResponse = {
  accessToken: string;
  refreshToken: string;
};

export type AuthResponse = JwtTokenResponse & {
  id: string;
  email: string;
};
