import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { postsService } from '@/services/posts.service';
import {
  Post,
  PostCreateInput,
  PostUpdateInput,
  PostFilters,
} from '@workspace/shared-types';

/**
 * Query keys for posts
 */
export const postKeys = {
  all: ['posts'] as const,
  lists: () => [...postKeys.all, 'list'] as const,
  list: (filters?: PostFilters) => [...postKeys.lists(), filters] as const,
  details: () => [...postKeys.all, 'detail'] as const,
  detail: (idOrSlug: string) => [...postKeys.details(), idOrSlug] as const,
};

/**
 * Hook to get list of posts
 */
export function usePosts(filters?: PostFilters) {
  return useQuery({
    queryKey: postKeys.list(filters),
    queryFn: async () => {
      const response = await postsService.getPosts(filters);
      if (!response.success) {
        throw new Error(response.error?.message || 'Failed to fetch posts');
      }
      return response.data!;
    },
  });
}

/**
 * Hook to get single post by ID or slug
 */
export function usePost(idOrSlug: string) {
  return useQuery({
    queryKey: postKeys.detail(idOrSlug),
    queryFn: async () => {
      const response = await postsService.getPost(idOrSlug);
      if (!response.success) {
        throw new Error(response.error?.message || 'Failed to fetch post');
      }
      return response.data!;
    },
    enabled: !!idOrSlug,
  });
}

/**
 * Hook to create post
 */
export function useCreatePost() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: PostCreateInput) => postsService.createPost(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: postKeys.lists() });
    },
  });
}

/**
 * Hook to update post
 */
export function useUpdatePost(id: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: PostUpdateInput) => postsService.updatePost(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: postKeys.detail(id) });
      queryClient.invalidateQueries({ queryKey: postKeys.lists() });
    },
  });
}

/**
 * Hook to delete post
 */
export function useDeletePost() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => postsService.deletePost(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: postKeys.lists() });
    },
  });
}

/**
 * Hook to publish post
 */
export function usePublishPost(id: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: () => postsService.publishPost(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: postKeys.detail(id) });
      queryClient.invalidateQueries({ queryKey: postKeys.lists() });
    },
  });
}

/**
 * Hook to archive post
 */
export function useArchivePost(id: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: () => postsService.archivePost(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: postKeys.detail(id) });
      queryClient.invalidateQueries({ queryKey: postKeys.lists() });
    },
  });
}
