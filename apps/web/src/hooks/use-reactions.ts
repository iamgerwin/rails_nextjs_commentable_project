import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { reactionsService } from '@/services/reactions.service';
import {
  ReactionType,
  ReactableType,
} from '@workspace/shared-types';

/**
 * Query keys for reactions
 */
export const reactionKeys = {
  all: ['reactions'] as const,
  reactable: (type: ReactableType, id: string) => [...reactionKeys.all, 'reactable', type, id] as const,
  summary: (type: ReactableType, id: string) => [...reactionKeys.reactable(type, id), 'summary'] as const,
};

/**
 * Hook to get reactions for a reactable entity
 */
export function useReactions(
  reactableType: ReactableType,
  reactableId: string,
  summary = false
) {
  return useQuery({
    queryKey: summary
      ? reactionKeys.summary(reactableType, reactableId)
      : reactionKeys.reactable(reactableType, reactableId),
    queryFn: async () => {
      const response = await reactionsService.getReactions(reactableType, reactableId, summary);
      if (!response.success) {
        throw new Error(response.error?.message || 'Failed to fetch reactions');
      }
      return response.data!;
    },
    enabled: !!reactableType && !!reactableId,
  });
}

/**
 * Hook to get reaction summary for a reactable entity
 */
export function useReactionSummary(reactableType: ReactableType, reactableId: string) {
  return useReactions(reactableType, reactableId, true);
}

/**
 * Hook to toggle reaction
 */
export function useToggleReaction(reactableType: ReactableType, reactableId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (typeName: ReactionType) =>
      reactionsService.react(reactableType, reactableId, typeName),
    onSuccess: () => {
      // Invalidate both the detailed list and the summary
      queryClient.invalidateQueries({
        queryKey: reactionKeys.reactable(reactableType, reactableId),
      });
      queryClient.invalidateQueries({
        queryKey: reactionKeys.summary(reactableType, reactableId),
      });
    },
  });
}

/**
 * Hook to delete reaction
 */
export function useDeleteReaction(reactableType: ReactableType, reactableId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (reactionId: string) => reactionsService.deleteReaction(reactionId),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: reactionKeys.reactable(reactableType, reactableId),
      });
      queryClient.invalidateQueries({
        queryKey: reactionKeys.summary(reactableType, reactableId),
      });
    },
  });
}
