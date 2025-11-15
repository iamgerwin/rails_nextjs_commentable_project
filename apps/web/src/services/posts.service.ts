import { apiClient } from '@/lib/api-client';
import {
  Post,
  PostCreateInput,
  PostUpdateInput,
  PostFilters,
  PaginatedResponse,
  ApiResponse,
} from '@workspace/shared-types';

class PostsService {
  /**
   * Get list of posts with filters
   */
  async getPosts(filters?: PostFilters): Promise<ApiResponse<PaginatedResponse<Post>>> {
    const queryString = filters ? apiClient.buildQueryString(this.buildRansackFilters(filters)) : '';
    return apiClient.get<PaginatedResponse<Post>>(`/posts${queryString}`);
  }

  /**
   * Get single post by ID or slug
   */
  async getPost(idOrSlug: string): Promise<ApiResponse<Post>> {
    return apiClient.get<Post>(`/posts/${idOrSlug}`);
  }

  /**
   * Create new post
   */
  async createPost(data: PostCreateInput): Promise<ApiResponse<Post>> {
    return apiClient.post<Post>('/posts', {
      post: {
        title: data.title,
        content: data.content,
        excerpt: data.excerpt,
        visibility: data.visibility,
        featured_image_url: data.featuredImageUrl,
        tags: data.tags,
        metadata: data.metadata,
      },
    });
  }

  /**
   * Update post
   */
  async updatePost(id: string, data: PostUpdateInput): Promise<ApiResponse<Post>> {
    return apiClient.patch<Post>(`/posts/${id}`, {
      post: {
        title: data.title,
        content: data.content,
        excerpt: data.excerpt,
        status: data.status,
        visibility: data.visibility,
        featured_image_url: data.featuredImageUrl,
        tags: data.tags,
        metadata: data.metadata,
      },
    });
  }

  /**
   * Delete post
   */
  async deletePost(id: string): Promise<ApiResponse<{ message: string }>> {
    return apiClient.delete<{ message: string }>(`/posts/${id}`);
  }

  /**
   * Publish post
   */
  async publishPost(id: string): Promise<ApiResponse<Post>> {
    return apiClient.post<Post>(`/posts/${id}/publish`);
  }

  /**
   * Archive post
   */
  async archivePost(id: string): Promise<ApiResponse<Post>> {
    return apiClient.post<Post>(`/posts/${id}/archive`);
  }

  /**
   * Build Ransack filters from PostFilters
   */
  private buildRansackFilters(filters: PostFilters): Record<string, unknown> {
    const ransackParams: Record<string, unknown> = {
      page: filters.page,
      per_page: filters.perPage,
    };

    const q: Record<string, unknown> = {};

    if (filters.search) {
      q.title_or_content_cont = filters.search;
    }

    if (filters.status) {
      q.status_eq = filters.status;
    }

    if (filters.visibility) {
      q.visibility_eq = filters.visibility;
    }

    if (filters.userId) {
      q.user_id_eq = filters.userId;
    }

    if (filters.tags && filters.tags.length > 0) {
      q.tags_cont_any = filters.tags;
    }

    if (filters.sortBy) {
      q.s = `${filters.sortBy} ${filters.sortOrder || 'desc'}`;
    }

    if (Object.keys(q).length > 0) {
      ransackParams.q = q;
    }

    return ransackParams;
  }
}

export const postsService = new PostsService();
