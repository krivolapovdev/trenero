export type JwtTokenResponse = {
  accessToken: string;
  refreshToken: string;
};

export type AuthResponse = {
  user: {
    id: string;
    email: string;
  };
  jwtToken: JwtTokenResponse;
};
