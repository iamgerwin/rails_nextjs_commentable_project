'use client';

import React, { createContext, useContext, useEffect, useState, useCallback } from 'react';
import { User } from '@workspace/shared-types';
import { TokenManager } from '@/lib/api-client';

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (data: RegisterData) => Promise<void>;
  logout: () => Promise<void>;
  refreshUser: () => Promise<void>;
}

interface RegisterData {
  email: string;
  username: string;
  password: string;
  passwordConfirmation: string;
  firstName: string;
  lastName: string;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const refreshUser = useCallback(async () => {
    const token = TokenManager.getAccessToken();
    if (!token) {
      setUser(null);
      setIsLoading(false);
      return;
    }

    try {
      // Import dynamically to avoid circular dependency
      const { authService } = await import('@/services/auth.service');
      const response = await authService.getCurrentUser();

      if (response.success && response.data) {
        setUser(response.data);
      } else {
        TokenManager.clearTokens();
        setUser(null);
      }
    } catch (error) {
      console.error('Failed to refresh user:', error);
      TokenManager.clearTokens();
      setUser(null);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    refreshUser();
  }, [refreshUser]);

  const login = async (email: string, password: string) => {
    setIsLoading(true);
    try {
      const { authService } = await import('@/services/auth.service');
      const response = await authService.login({ email, password });

      if (!response.success || !response.data) {
        return response;
      }

      const { user, tokens } = response.data;
      TokenManager.setTokens(tokens.accessToken, tokens.refreshToken);
      setUser(user);

      return response;
    } finally {
      setIsLoading(false);
    }
  };

  const register = async (data: RegisterData) => {
    setIsLoading(true);
    try {
      const { authService } = await import('@/services/auth.service');
      const response = await authService.register(data);

      if (!response.success || !response.data) {
        return response;
      }

      const { user, tokens } = response.data;
      TokenManager.setTokens(tokens.accessToken, tokens.refreshToken);
      setUser(user);

      return response;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async () => {
    setIsLoading(true);
    try {
      const { authService } = await import('@/services/auth.service');
      await authService.logout();
    } finally {
      TokenManager.clearTokens();
      setUser(null);
      setIsLoading(false);
    }
  };

  const value: AuthContextType = {
    user,
    isAuthenticated: !!user,
    isLoading,
    login,
    register,
    logout,
    refreshUser,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
