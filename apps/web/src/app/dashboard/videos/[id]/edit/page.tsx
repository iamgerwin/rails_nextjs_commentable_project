'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import { ProtectedRoute } from '@/components/auth/protected-route';
import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { VideoForm } from '@/components/forms/video-form';
import { videosService } from '@/services/videos.service';
import { Video } from '@workspace/shared-types';

function EditVideoContent() {
  const params = useParams();
  const videoId = params.id as string;
  const [video, setVideo] = useState<Video | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (videoId) {
      fetchVideo();
    }
  }, [videoId]);

  const fetchVideo = async () => {
    try {
      const response = await videosService.getVideo(videoId);
      if (response.success && response.data) {
        setVideo(response.data);
      }
    } catch (error) {
      console.error('Failed to fetch video:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <DashboardLayout>
        <div className="space-y-6">
          <div className="h-8 w-48 bg-muted animate-pulse rounded" />
          <div className="h-96 bg-muted animate-pulse rounded" />
        </div>
      </DashboardLayout>
    );
  }

  if (!video) {
    return (
      <DashboardLayout>
        <div className="text-center py-12">
          <h2 className="text-2xl font-bold">Video not found</h2>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Edit Video</h2>
          <p className="text-muted-foreground">
            Update video details and settings
          </p>
        </div>

        <VideoForm mode="edit" video={video} />
      </div>
    </DashboardLayout>
  );
}

export default function EditVideoPage() {
  return (
    <ProtectedRoute requireAuth>
      <EditVideoContent />
    </ProtectedRoute>
  );
}
