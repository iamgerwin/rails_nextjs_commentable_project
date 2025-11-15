import { apiClient } from '@/lib/api-client';
import {
  Reaction,
  ReactionSummary,
  ReactionType,
  ReactableType,
  PaginatedResponse,
  ApiResponse,
} from '@workspace/shared-types';

class ReactionsService {
  /**
   * Get reactions for a video
   */
  async getVideoReactions(
    videoId: string,
    summary = false
  ): Promise<ApiResponse<PaginatedResponse<Reaction> | ReactionSummary>> {
    const queryString = summary ? '?summary=true' : '';
    return apiClient.get<PaginatedResponse<Reaction> | ReactionSummary>(
      `/videos/${videoId}/reactions${queryString}`
    );
  }

  /**
   * Get reactions for a post
   */
  async getPostReactions(
    postId: string,
    summary = false
  ): Promise<ApiResponse<PaginatedResponse<Reaction> | ReactionSummary>> {
    const queryString = summary ? '?summary=true' : '';
    return apiClient.get<PaginatedResponse<Reaction> | ReactionSummary>(
      `/posts/${postId}/reactions${queryString}`
    );
  }

  /**
   * Get reactions for a comment
   */
  async getCommentReactions(
    commentId: string,
    summary = false
  ): Promise<ApiResponse<PaginatedResponse<Reaction> | ReactionSummary>> {
    const queryString = summary ? '?summary=true' : '';
    return apiClient.get<PaginatedResponse<Reaction> | ReactionSummary>(
      `/comments/${commentId}/reactions${queryString}`
    );
  }

  /**
   * Create or toggle reaction on video
   */
  async reactToVideo(videoId: string, typeName: ReactionType): Promise<ApiResponse<Reaction | { message: string; action: string; type: string }>> {
    return apiClient.post<Reaction | { message: string; action: string; type: string }>(
      `/videos/${videoId}/reactions`,
      {
        reaction: { type_name: typeName },
      }
    );
  }

  /**
   * Create or toggle reaction on post
   */
  async reactToPost(postId: string, typeName: ReactionType): Promise<ApiResponse<Reaction | { message: string; action: string; type: string }>> {
    return apiClient.post<Reaction | { message: string; action: string; type: string }>(
      `/posts/${postId}/reactions`,
      {
        reaction: { type_name: typeName },
      }
    );
  }

  /**
   * Create or toggle reaction on comment
   */
  async reactToComment(commentId: string, typeName: ReactionType): Promise<ApiResponse<Reaction | { message: string; action: string; type: string }>> {
    return apiClient.post<Reaction | { message: string; action: string; type: string }>(
      `/comments/${commentId}/reactions`,
      {
        reaction: { type_name: typeName },
      }
    );
  }

  /**
   * Delete reaction
   */
  async deleteReaction(reactionId: string): Promise<ApiResponse<{ message: string }>> {
    return apiClient.delete<{ message: string }>(`/reactions/${reactionId}`);
  }

  /**
   * Generic react method
   */
  async react(
    reactableType: ReactableType,
    reactableId: string,
    typeName: ReactionType
  ): Promise<ApiResponse<Reaction | { message: string; action: string; type: string }>> {
    switch (reactableType) {
      case 'Video':
        return this.reactToVideo(reactableId, typeName);
      case 'Post':
        return this.reactToPost(reactableId, typeName);
      case 'Comment':
        return this.reactToComment(reactableId, typeName);
      default:
        throw new Error(`Unknown reactable type: ${reactableType}`);
    }
  }

  /**
   * Generic get reactions method
   */
  async getReactions(
    reactableType: ReactableType,
    reactableId: string,
    summary = false
  ): Promise<ApiResponse<PaginatedResponse<Reaction> | ReactionSummary>> {
    switch (reactableType) {
      case 'Video':
        return this.getVideoReactions(reactableId, summary);
      case 'Post':
        return this.getPostReactions(reactableId, summary);
      case 'Comment':
        return this.getCommentReactions(reactableId, summary);
      default:
        throw new Error(`Unknown reactable type: ${reactableType}`);
    }
  }
}

export const reactionsService = new ReactionsService();
