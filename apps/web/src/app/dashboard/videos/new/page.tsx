'use client';

import { ProtectedRoute } from '@/components/auth/protected-route';
import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { VideoForm } from '@/components/forms/video-form';

function NewVideoContent() {
  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Create New Video</h2>
          <p className="text-muted-foreground">
            Upload a new video to the platform
          </p>
        </div>

        <VideoForm mode="create" />
      </div>
    </DashboardLayout>
  );
}

export default function NewVideoPage() {
  return (
    <ProtectedRoute requireAuth>
      <NewVideoContent />
    </ProtectedRoute>
  );
}
