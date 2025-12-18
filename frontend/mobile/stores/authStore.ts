import AsyncStorage from '@react-native-async-storage/async-storage';
import * as SecureStore from 'expo-secure-store';
import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';

type User = {
  id: string;
  email: string;
};

type AuthStore = {
  user: User | null;
  accessToken: string | null;
  setAuth: (
    user: User,
    accessToken: string,
    refreshToken: string
  ) => Promise<void>;
  logout: () => Promise<void>;
  getRefreshToken: () => Promise<string | null>;
};

export const useAuthStore = create<AuthStore>()(
  persist(
    set => ({
      user: null,
      accessToken: null,

      setAuth: async (user, accessToken, refreshToken) => {
        set({ user, accessToken });

        await SecureStore.setItemAsync('refresh_token', refreshToken);
      },

      logout: async () => {
        set({ user: null, accessToken: null });
        await SecureStore.deleteItemAsync('refresh_token');
      },

      getRefreshToken: async () => {
        return await SecureStore.getItemAsync('refresh_token');
      }
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: state => ({ user: state.user })
    }
  )
);
