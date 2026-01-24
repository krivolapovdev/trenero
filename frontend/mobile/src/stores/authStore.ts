import AsyncStorage from '@react-native-async-storage/async-storage';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import * as SecureStore from 'expo-secure-store';
import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';
import type { components } from '@/src/api/generated/openapi';

type AuthStore = {
  user: components['schemas']['UserResponse'] | null;
  accessToken: string | null;
  setAuth: (payload: components['schemas']['LoginResponse']) => Promise<void>;
  logout: () => Promise<void>;
  getRefreshToken: () => Promise<string | null>;
};

export const useAuthStore = create<AuthStore>()(
  persist(
    set => ({
      user: null,
      accessToken: null,

      setAuth: async payload => {
        set({ user: payload.user, accessToken: payload.jwtTokens.accessToken });
        await SecureStore.setItemAsync(
          'refresh_token',
          payload.jwtTokens.refreshToken
        );
      },

      logout: async () => {
        set({ user: null, accessToken: null });
        await SecureStore.deleteItemAsync('refresh_token');
        await GoogleSignin.signOut();
      },

      getRefreshToken: async () =>
        await SecureStore.getItemAsync('refresh_token')
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: state => ({ user: state.user })
    }
  )
);
