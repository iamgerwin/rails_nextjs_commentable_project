import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { commentsService } from '@/services/comments.service';
import {
  Comment,
  CommentFilters,
  CommentableType,
} from '@workspace/shared-types';

/**
 * Query keys for comments
 */
export const commentKeys = {
  all: ['comments'] as const,
  lists: () => [...commentKeys.all, 'list'] as const,
  list: (filters?: CommentFilters) => [...commentKeys.lists(), filters] as const,
  commentable: (type: CommentableType, id: string) => [...commentKeys.all, 'commentable', type, id] as const,
  details: () => [...commentKeys.all, 'detail'] as const,
  detail: (id: string) => [...commentKeys.details(), id] as const,
};

/**
 * Hook to get list of comments
 */
export function useComments(filters?: CommentFilters) {
  return useQuery({
    queryKey: commentKeys.list(filters),
    queryFn: async () => {
      const response = await commentsService.getComments(filters);
      if (!response.success) {
        throw new Error(response.error?.message || 'Failed to fetch comments');
      }
      return response.data!;
    },
  });
}

/**
 * Hook to get comments for a commentable entity
 */
export function useCommentableComments(
  commentableType: CommentableType,
  commentableId: string,
  filters?: CommentFilters
) {
  return useQuery({
    queryKey: commentKeys.commentable(commentableType, commentableId),
    queryFn: async () => {
      const response = await commentsService.getCommentableComments(
        commentableType,
        commentableId,
        filters
      );
      if (!response.success) {
        throw new Error(response.error?.message || 'Failed to fetch comments');
      }
      return response.data!;
    },
    enabled: !!commentableType && !!commentableId,
  });
}

/**
 * Hook to get single comment
 */
export function useComment(id: string, includeReplies = false) {
  return useQuery({
    queryKey: [...commentKeys.detail(id), { includeReplies }],
    queryFn: async () => {
      const response = await commentsService.getComment(id, includeReplies);
      if (!response.success) {
        throw new Error(response.error?.message || 'Failed to fetch comment');
      }
      return response.data!;
    },
    enabled: !!id,
  });
}

/**
 * Hook to create comment on video
 */
export function useCreateVideoComment(videoId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (content: string) => commentsService.createVideoComment(videoId, content),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: commentKeys.commentable('Video', videoId) });
    },
  });
}

/**
 * Hook to create comment on post
 */
export function useCreatePostComment(postId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (content: string) => commentsService.createPostComment(postId, content),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: commentKeys.commentable('Post', postId) });
    },
  });
}

/**
 * Hook to create reply to a comment
 */
export function useCreateReply(commentId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (content: string) => commentsService.createReply(commentId, content),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: commentKeys.detail(commentId) });
    },
  });
}

/**
 * Hook to update comment
 */
export function useUpdateComment(id: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: { content?: string; status?: string }) =>
      commentsService.updateComment(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: commentKeys.detail(id) });
    },
  });
}

/**
 * Hook to delete comment
 */
export function useDeleteComment() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => commentsService.deleteComment(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: commentKeys.lists() });
    },
  });
}
