import { apiClient } from '@/lib/api-client';
import { User, ApiResponse } from '@workspace/shared-types';

interface LoginRequest {
  email: string;
  password: string;
}

interface RegisterRequest {
  email: string;
  username: string;
  password: string;
  passwordConfirmation: string;
  firstName: string;
  lastName: string;
}

interface AuthResponse {
  user: User;
  tokens: {
    accessToken: string;
    refreshToken: string;
  };
}

interface RefreshTokenRequest {
  refreshToken: string;
}

interface VerifyEmailRequest {
  token: string;
}

interface ForgotPasswordRequest {
  email: string;
}

interface ResetPasswordRequest {
  token: string;
  password: string;
  passwordConfirmation: string;
}

class AuthService {
  /**
   * Login user
   */
  async login(credentials: LoginRequest): Promise<ApiResponse<AuthResponse>> {
    return apiClient.post<AuthResponse>('/auth/login', credentials);
  }

  /**
   * Register new user
   */
  async register(data: RegisterRequest): Promise<ApiResponse<AuthResponse>> {
    return apiClient.post<AuthResponse>('/auth/register', {
      email: data.email,
      username: data.username,
      password: data.password,
      password_confirmation: data.passwordConfirmation,
      first_name: data.firstName,
      last_name: data.lastName,
    });
  }

  /**
   * Refresh access token
   */
  async refreshToken(refreshToken: string): Promise<ApiResponse<{ tokens: AuthResponse['tokens'] }>> {
    return apiClient.post<{ tokens: AuthResponse['tokens'] }>('/auth/refresh', {
      refresh_token: refreshToken,
    });
  }

  /**
   * Logout user
   */
  async logout(): Promise<ApiResponse<{ message: string }>> {
    return apiClient.delete<{ message: string }>('/auth/logout');
  }

  /**
   * Verify email
   */
  async verifyEmail(token: string): Promise<ApiResponse<{ message: string }>> {
    return apiClient.post<{ message: string }>('/auth/verify_email', { token });
  }

  /**
   * Request password reset
   */
  async forgotPassword(email: string): Promise<ApiResponse<{ message: string }>> {
    return apiClient.post<{ message: string }>('/auth/forgot_password', { email });
  }

  /**
   * Reset password
   */
  async resetPassword(data: ResetPasswordRequest): Promise<ApiResponse<{ message: string }>> {
    return apiClient.post<{ message: string }>('/auth/reset_password', {
      token: data.token,
      password: data.password,
      password_confirmation: data.passwordConfirmation,
    });
  }

  /**
   * Get current user
   * This is useful for refreshing user data
   */
  async getCurrentUser(): Promise<ApiResponse<User>> {
    // Assuming there's a "me" endpoint or we can get user from token
    // If not available, we'll need to modify this
    return apiClient.get<User>('/users/me');
  }
}

export const authService = new AuthService();
