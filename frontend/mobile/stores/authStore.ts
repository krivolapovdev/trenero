import AsyncStorage from '@react-native-async-storage/async-storage';
import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';

type User = {
  id: string;
  email: string;
};

type AuthStore = {
  user: User | null;
  accessToken: string | null;
  setAuth: (user: User, token: string) => void;
  logout: () => void;
};

export const useAuthStore = create<AuthStore>()(
  persist(
    set => ({
      user: null,
      accessToken: null,

      setAuth: (user, token) =>
        set({
          user,
          accessToken: token
        }),

      logout: () =>
        set({
          user: null,
          accessToken: null
        })
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: state => ({ user: state.user })
    }
  )
);
