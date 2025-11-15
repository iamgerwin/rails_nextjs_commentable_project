import { apiClient } from '@/lib/api-client';
import {
  Comment,
  CommentCreateInput,
  CommentUpdateInput,
  CommentFilters,
  PaginatedResponse,
  ApiResponse,
  CommentableType,
} from '@workspace/shared-types';

class CommentsService {
  /**
   * Get list of comments with filters
   */
  async getComments(filters?: CommentFilters): Promise<ApiResponse<PaginatedResponse<Comment>>> {
    const queryString = filters ? apiClient.buildQueryString(this.buildRansackFilters(filters)) : '';
    return apiClient.get<PaginatedResponse<Comment>>(`/comments${queryString}`);
  }

  /**
   * Get comments for a specific commentable (video or post)
   */
  async getCommentableComments(
    commentableType: CommentableType,
    commentableId: string,
    filters?: CommentFilters
  ): Promise<ApiResponse<PaginatedResponse<Comment>>> {
    const basePath = commentableType === 'Video' ? 'videos' : 'posts';
    const queryString = filters ? apiClient.buildQueryString(this.buildRansackFilters(filters)) : '';
    return apiClient.get<PaginatedResponse<Comment>>(`/${basePath}/${commentableId}/comments${queryString}`);
  }

  /**
   * Get single comment by ID
   */
  async getComment(id: string, includeReplies = false): Promise<ApiResponse<Comment>> {
    const queryString = includeReplies ? '?include_replies=true' : '';
    return apiClient.get<Comment>(`/comments/${id}${queryString}`);
  }

  /**
   * Create comment on video
   */
  async createVideoComment(videoId: string, content: string): Promise<ApiResponse<Comment>> {
    return apiClient.post<Comment>(`/videos/${videoId}/comments`, {
      comment: { content },
    });
  }

  /**
   * Create comment on post
   */
  async createPostComment(postId: string, content: string): Promise<ApiResponse<Comment>> {
    return apiClient.post<Comment>(`/posts/${postId}/comments`, {
      comment: { content },
    });
  }

  /**
   * Create reply to a comment
   */
  async createReply(commentId: string, content: string): Promise<ApiResponse<Comment>> {
    return apiClient.post<Comment>(`/comments/${commentId}/replies`, {
      comment: { content },
    });
  }

  /**
   * Update comment
   */
  async updateComment(id: string, data: CommentUpdateInput): Promise<ApiResponse<Comment>> {
    return apiClient.patch<Comment>(`/comments/${id}`, {
      comment: {
        content: data.content,
        status: data.status,
      },
    });
  }

  /**
   * Delete comment
   */
  async deleteComment(id: string): Promise<ApiResponse<{ message: string }>> {
    return apiClient.delete<{ message: string }>(`/comments/${id}`);
  }

  /**
   * Build Ransack filters from CommentFilters
   */
  private buildRansackFilters(filters: CommentFilters): Record<string, unknown> {
    const ransackParams: Record<string, unknown> = {
      page: filters.page,
      per_page: filters.perPage,
    };

    const q: Record<string, unknown> = {};

    if (filters.userId) {
      q.user_id_eq = filters.userId;
    }

    if (filters.commentableType) {
      q.commentable_type_eq = filters.commentableType;
    }

    if (filters.commentableId) {
      q.commentable_id_eq = filters.commentableId;
    }

    if (filters.status) {
      q.status_eq = filters.status;
    }

    if (filters.parentId === null) {
      q.parent_id_null = true;
    } else if (filters.parentId) {
      q.parent_id_eq = filters.parentId;
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

export const commentsService = new CommentsService();
