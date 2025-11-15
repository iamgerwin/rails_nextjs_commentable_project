import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { videosService } from '@/services/videos.service';
import {
  Video,
  VideoCreateInput,
  VideoUpdateInput,
  VideoFilters,
} from '@workspace/shared-types';

/**
 * Query keys for videos
 */
export const videoKeys = {
  all: ['videos'] as const,
  lists: () => [...videoKeys.all, 'list'] as const,
  list: (filters?: VideoFilters) => [...videoKeys.lists(), filters] as const,
  details: () => [...videoKeys.all, 'detail'] as const,
  detail: (id: string) => [...videoKeys.details(), id] as const,
};

/**
 * Hook to get list of videos
 */
export function useVideos(filters?: VideoFilters) {
  return useQuery({
    queryKey: videoKeys.list(filters),
    queryFn: async () => {
      const response = await videosService.getVideos(filters);
      if (!response.success) {
        throw new Error(response.error?.message || 'Failed to fetch videos');
      }
      return response.data!;
    },
  });
}

/**
 * Hook to get single video
 */
export function useVideo(id: string) {
  return useQuery({
    queryKey: videoKeys.detail(id),
    queryFn: async () => {
      const response = await videosService.getVideo(id);
      if (!response.success) {
        throw new Error(response.error?.message || 'Failed to fetch video');
      }
      return response.data!;
    },
    enabled: !!id,
  });
}

/**
 * Hook to create video
 */
export function useCreateVideo() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: VideoCreateInput) => videosService.createVideo(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: videoKeys.lists() });
    },
  });
}

/**
 * Hook to update video
 */
export function useUpdateVideo(id: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: VideoUpdateInput) => videosService.updateVideo(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: videoKeys.detail(id) });
      queryClient.invalidateQueries({ queryKey: videoKeys.lists() });
    },
  });
}

/**
 * Hook to delete video
 */
export function useDeleteVideo() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => videosService.deleteVideo(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: videoKeys.lists() });
    },
  });
}

/**
 * Hook to publish video
 */
export function usePublishVideo(id: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: () => videosService.publishVideo(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: videoKeys.detail(id) });
      queryClient.invalidateQueries({ queryKey: videoKeys.lists() });
    },
  });
}

/**
 * Hook to archive video
 */
export function useArchiveVideo(id: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: () => videosService.archiveVideo(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: videoKeys.detail(id) });
      queryClient.invalidateQueries({ queryKey: videoKeys.lists() });
    },
  });
}
