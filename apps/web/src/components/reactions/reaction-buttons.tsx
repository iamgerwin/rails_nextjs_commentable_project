'use client';

import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { reactionsService } from '@/services/reactions.service';
import { ReactionType, ReactableType, ReactionSummary } from '@workspace/shared-types';
import { ThumbsUp, ThumbsDown, Heart, Sparkles } from 'lucide-react';
import { cn } from '@/lib/utils';

interface ReactionButtonsProps {
  reactableType: ReactableType;
  reactableId: string;
  initialSummary?: ReactionSummary;
  showCounts?: boolean;
  size?: 'sm' | 'md' | 'lg';
}

const reactionIcons: Record<ReactionType, React.ReactNode> = {
  [ReactionType.LIKE]: <ThumbsUp className="h-4 w-4" />,
  [ReactionType.DISLIKE]: <ThumbsDown className="h-4 w-4" />,
  [ReactionType.LOVE]: <Heart className="h-4 w-4" />,
  [ReactionType.CLAP]: <Sparkles className="h-4 w-4" />,
};

const reactionLabels: Record<ReactionType, string> = {
  [ReactionType.LIKE]: 'Like',
  [ReactionType.DISLIKE]: 'Dislike',
  [ReactionType.LOVE]: 'Love',
  [ReactionType.CLAP]: 'Clap',
};

export function ReactionButtons({
  reactableType,
  reactableId,
  initialSummary,
  showCounts = true,
  size = 'md',
}: ReactionButtonsProps) {
  const [summary, setSummary] = useState<ReactionSummary | null>(initialSummary || null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!initialSummary) {
      fetchSummary();
    }
  }, [reactableId, reactableType]);

  const fetchSummary = async () => {
    try {
      const response = await reactionsService.getReactions(reactableType, reactableId, true);
      if (response.success && response.data) {
        setSummary(response.data as ReactionSummary);
      }
    } catch (error) {
      console.error('Failed to fetch reactions:', error);
    }
  };

  const handleReaction = async (reactionType: ReactionType) => {
    if (loading) return;

    setLoading(true);
    try {
      const response = await reactionsService.react(reactableType, reactableId, reactionType);
      if (response.success) {
        // Refresh the summary after reaction
        await fetchSummary();
      }
    } catch (error) {
      console.error('Failed to react:', error);
    } finally {
      setLoading(false);
    }
  };

  const getButtonSize = () => {
    switch (size) {
      case 'sm':
        return 'sm';
      case 'lg':
        return 'lg';
      default:
        return 'default';
    }
  };

  if (!summary) {
    return (
      <div className="flex items-center gap-2">
        <div className="h-8 w-20 bg-muted animate-pulse rounded" />
        <div className="h-8 w-20 bg-muted animate-pulse rounded" />
      </div>
    );
  }

  return (
    <div className="flex items-center gap-2 flex-wrap">
      {/* Like Button */}
      <Button
        variant={summary.userReaction === ReactionType.LIKE ? 'default' : 'outline'}
        size={getButtonSize()}
        onClick={() => handleReaction(ReactionType.LIKE)}
        disabled={loading}
        className={cn(
          'gap-2',
          summary.userReaction === ReactionType.LIKE && 'bg-blue-500 hover:bg-blue-600'
        )}
      >
        {reactionIcons[ReactionType.LIKE]}
        {showCounts && summary[ReactionType.LIKE] > 0 && (
          <span className="text-sm">{summary[ReactionType.LIKE]}</span>
        )}
      </Button>

      {/* Love Button */}
      <Button
        variant={summary.userReaction === ReactionType.LOVE ? 'default' : 'outline'}
        size={getButtonSize()}
        onClick={() => handleReaction(ReactionType.LOVE)}
        disabled={loading}
        className={cn(
          'gap-2',
          summary.userReaction === ReactionType.LOVE && 'bg-red-500 hover:bg-red-600'
        )}
      >
        {reactionIcons[ReactionType.LOVE]}
        {showCounts && summary[ReactionType.LOVE] > 0 && (
          <span className="text-sm">{summary[ReactionType.LOVE]}</span>
        )}
      </Button>

      {/* Clap Button */}
      <Button
        variant={summary.userReaction === ReactionType.CLAP ? 'default' : 'outline'}
        size={getButtonSize()}
        onClick={() => handleReaction(ReactionType.CLAP)}
        disabled={loading}
        className={cn(
          'gap-2',
          summary.userReaction === ReactionType.CLAP && 'bg-yellow-500 hover:bg-yellow-600'
        )}
      >
        {reactionIcons[ReactionType.CLAP]}
        {showCounts && summary[ReactionType.CLAP] > 0 && (
          <span className="text-sm">{summary[ReactionType.CLAP]}</span>
        )}
      </Button>

      {/* Dislike Button */}
      <Button
        variant={summary.userReaction === ReactionType.DISLIKE ? 'default' : 'outline'}
        size={getButtonSize()}
        onClick={() => handleReaction(ReactionType.DISLIKE)}
        disabled={loading}
        className={cn(
          'gap-2',
          summary.userReaction === ReactionType.DISLIKE && 'bg-gray-600 hover:bg-gray-700'
        )}
      >
        {reactionIcons[ReactionType.DISLIKE]}
        {showCounts && summary[ReactionType.DISLIKE] > 0 && (
          <span className="text-sm">{summary[ReactionType.DISLIKE]}</span>
        )}
      </Button>

      {showCounts && summary.total > 0 && (
        <span className="text-sm text-muted-foreground ml-2">
          {summary.total} {summary.total === 1 ? 'reaction' : 'reactions'}
        </span>
      )}
    </div>
  );
}
