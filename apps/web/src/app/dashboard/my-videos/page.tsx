'use client';

import { ProtectedRoute } from '@/components/auth/protected-route';
import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Video, Plus } from 'lucide-react';

function MyVideosContent() {
  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-3xl font-bold tracking-tight">My Videos</h2>
            <p className="text-muted-foreground">
              Manage your uploaded videos
            </p>
          </div>
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            Upload Video
          </Button>
        </div>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Video className="h-5 w-5" />
              Your Videos
            </CardTitle>
            <CardDescription>
              View and manage videos you&apos;ve uploaded
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <Video className="h-12 w-12 text-muted-foreground mb-4" />
              <h3 className="text-lg font-semibold mb-2">No Videos Yet</h3>
              <p className="text-sm text-muted-foreground max-w-sm mb-4">
                You haven&apos;t uploaded any videos yet. Start by uploading your first video to
                share with the community.
              </p>
              <Button>
                <Plus className="mr-2 h-4 w-4" />
                Upload Your First Video
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
}

export default function MyVideosPage() {
  return (
    <ProtectedRoute requireAuth>
      <MyVideosContent />
    </ProtectedRoute>
  );
}
