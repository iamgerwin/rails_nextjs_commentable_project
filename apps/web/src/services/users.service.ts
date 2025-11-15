import { apiClient } from '@/lib/api-client';
import {
  User,
  Video,
  Post,
  Comment,
  PaginatedResponse,
  ApiResponse,
  PaginationParams,
} from '@workspace/shared-types';

interface UserUpdateInput {
  username?: string;
  firstName?: string;
  lastName?: string;
  bio?: string;
  avatar?: string;
  email?: string;
  password?: string;
  passwordConfirmation?: string;
}

interface UserProfileResponse extends User {
  statistics?: {
    videosCount: number;
    postsCount: number;
    commentsCount: number;
    reactionsGiven: number;
    totalViews: number;
  };
}

class UsersService {
  /**
   * Get list of users
   */
  async getUsers(params?: PaginationParams): Promise<ApiResponse<PaginatedResponse<User>>> {
    const queryString = params ? apiClient.buildQueryString(params) : '';
    return apiClient.get<PaginatedResponse<User>>(`/users${queryString}`);
  }

  /**
   * Get user by ID or username
   */
  async getUser(idOrUsername: string): Promise<ApiResponse<User>> {
    return apiClient.get<User>(`/users/${idOrUsername}`);
  }

  /**
   * Get user profile with statistics
   */
  async getUserProfile(idOrUsername: string): Promise<ApiResponse<UserProfileResponse>> {
    return apiClient.get<UserProfileResponse>(`/users/${idOrUsername}/profile`);
  }

  /**
   * Get user's videos
   */
  async getUserVideos(
    idOrUsername: string,
    params?: PaginationParams
  ): Promise<ApiResponse<PaginatedResponse<Video>>> {
    const queryString = params ? apiClient.buildQueryString(params) : '';
    return apiClient.get<PaginatedResponse<Video>>(`/users/${idOrUsername}/videos${queryString}`);
  }

  /**
   * Get user's posts
   */
  async getUserPosts(
    idOrUsername: string,
    params?: PaginationParams
  ): Promise<ApiResponse<PaginatedResponse<Post>>> {
    const queryString = params ? apiClient.buildQueryString(params) : '';
    return apiClient.get<PaginatedResponse<Post>>(`/users/${idOrUsername}/posts${queryString}`);
  }

  /**
   * Get user's comments
   */
  async getUserComments(
    idOrUsername: string,
    params?: PaginationParams
  ): Promise<ApiResponse<PaginatedResponse<Comment>>> {
    const queryString = params ? apiClient.buildQueryString(params) : '';
    return apiClient.get<PaginatedResponse<Comment>>(`/users/${idOrUsername}/comments${queryString}`);
  }

  /**
   * Update user profile
   */
  async updateUser(id: string, data: UserUpdateInput): Promise<ApiResponse<User>> {
    return apiClient.patch<User>(`/users/${id}`, {
      user: {
        username: data.username,
        first_name: data.firstName,
        last_name: data.lastName,
        bio: data.bio,
        avatar: data.avatar,
        email: data.email,
        password: data.password,
        password_confirmation: data.passwordConfirmation,
      },
    });
  }

  /**
   * Delete user account
   */
  async deleteUser(id: string): Promise<ApiResponse<{ message: string }>> {
    return apiClient.delete<{ message: string }>(`/users/${id}`);
  }
}

export const usersService = new UsersService();
