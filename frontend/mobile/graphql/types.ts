export type JwtTokens = {
  accessToken: string;
  refreshToken: string;
};

export type User = {
  id: string;
  email: string;
};

export type LoginPayload = {
  user: User;
  jwtTokens: JwtTokens;
};

export type SocialLoginInput = {
  idToken: string;
};
