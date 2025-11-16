'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { ReactionButtons } from '@/components/reactions';
import { CommentSection } from '@/components/comments';
import { videosService } from '@/services/videos.service';
import { Video, VideoStatus, VideoVisibility, ReactableType, CommentableType } from '@workspace/shared-types';
import { ArrowLeft, Eye, Calendar, User, Clock } from 'lucide-react';

export default function VideoDetailPage() {
  const params = useParams();
  const router = useRouter();
  const videoId = params.id as string;

  const [video, setVideo] = useState<Video | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (videoId) {
      fetchVideo();
    }
  }, [videoId]);

  const fetchVideo = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await videosService.getVideo(videoId);
      if (response.success && response.data) {
        setVideo(response.data);
      } else {
        setError('Video not found');
      }
    } catch (err) {
      console.error('Failed to fetch video:', err);
      setError('Failed to load video');
    } finally {
      setLoading(false);
    }
  };

  const formatDuration = (seconds: number) => {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${minutes}:${secs.toString().padStart(2, '0')}`;
  };

  const getStatusBadge = (status: VideoStatus) => {
    const variants: Record<VideoStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      [VideoStatus.DRAFT]: 'secondary',
      [VideoStatus.PROCESSING]: 'outline',
      [VideoStatus.PUBLISHED]: 'default',
      [VideoStatus.ARCHIVED]: 'outline',
      [VideoStatus.DELETED]: 'destructive',
    };

    return <Badge variant={variants[status]}>{status}</Badge>;
  };

  const getVisibilityBadge = (visibility: VideoVisibility) => {
    const variants: Record<VideoVisibility, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      [VideoVisibility.PUBLIC]: 'default',
      [VideoVisibility.PRIVATE]: 'secondary',
      [VideoVisibility.UNLISTED]: 'outline',
    };

    return <Badge variant={variants[visibility]}>{visibility}</Badge>;
  };

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-6xl mx-auto space-y-6">
          <div className="h-8 w-32 bg-muted animate-pulse rounded" />
          <div className="aspect-video bg-muted animate-pulse rounded-lg" />
          <div className="h-8 w-3/4 bg-muted animate-pulse rounded" />
          <div className="h-24 bg-muted animate-pulse rounded" />
        </div>
      </div>
    );
  }

  if (error || !video) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-6xl mx-auto text-center">
          <h1 className="text-2xl font-bold mb-4">{error || 'Video not found'}</h1>
          <Button onClick={() => router.back()}>
            <ArrowLeft className="mr-2 h-4 w-4" />
            Go Back
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="max-w-6xl mx-auto space-y-6">
        {/* Back Button */}
        <Button variant="ghost" onClick={() => router.back()}>
          <ArrowLeft className="mr-2 h-4 w-4" />
          Back
        </Button>

        {/* Video Player */}
        <div className="relative aspect-video bg-black rounded-lg overflow-hidden">
          {video.thumbnailUrl ? (
            <video
              src={video.url}
              poster={video.thumbnailUrl}
              controls
              className="w-full h-full"
            >
              Your browser does not support the video tag.
            </video>
          ) : (
            <video src={video.url} controls className="w-full h-full">
              Your browser does not support the video tag.
            </video>
          )}
        </div>

        {/* Video Info */}
        <div className="space-y-4">
          <div className="flex items-start justify-between gap-4">
            <div className="flex-1">
              <h1 className="text-3xl font-bold mb-2">{video.title}</h1>
              <div className="flex flex-wrap items-center gap-3 text-sm text-muted-foreground">
                {video.user && (
                  <div className="flex items-center gap-1">
                    <User className="h-4 w-4" />
                    <span>{video.user.username}</span>
                  </div>
                )}
                <div className="flex items-center gap-1">
                  <Eye className="h-4 w-4" />
                  <span>{video.viewsCount} views</span>
                </div>
                <div className="flex items-center gap-1">
                  <Clock className="h-4 w-4" />
                  <span>{formatDuration(video.duration)}</span>
                </div>
                <div className="flex items-center gap-1">
                  <Calendar className="h-4 w-4" />
                  <span>{new Date(video.createdAt).toLocaleDateString()}</span>
                </div>
              </div>
            </div>

            <div className="flex gap-2">
              {getStatusBadge(video.status)}
              {getVisibilityBadge(video.visibility)}
            </div>
          </div>

          {/* Description */}
          {video.description && (
            <div className="prose max-w-none">
              <p className="text-muted-foreground whitespace-pre-wrap">{video.description}</p>
            </div>
          )}

          {/* Tags */}
          {video.tags && video.tags.length > 0 && (
            <div className="flex flex-wrap gap-2">
              {video.tags.map((tag, index) => (
                <Badge key={index} variant="outline">
                  {tag}
                </Badge>
              ))}
            </div>
          )}

          {/* Reactions */}
          <div className="border-y py-4">
            <ReactionButtons reactableType={ReactableType.VIDEO} reactableId={video.id} showCounts={true} />
          </div>

          {/* Comments */}
          <div className="pt-6">
            <CommentSection commentableType={CommentableType.VIDEO} commentableId={video.id} />
          </div>
        </div>
      </div>
    </div>
  );
}
