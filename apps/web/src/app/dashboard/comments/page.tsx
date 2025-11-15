'use client';

import { ProtectedRoute } from '@/components/auth/protected-route';
import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Shield } from 'lucide-react';

function CommentsModerationContent() {
  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Comments Moderation</h2>
          <p className="text-muted-foreground">
            Moderate and manage comments across the platform
          </p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Shield className="h-5 w-5" />
              Comments
            </CardTitle>
            <CardDescription>
              Review and moderate user comments
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <Shield className="h-12 w-12 text-muted-foreground mb-4" />
              <h3 className="text-lg font-semibold mb-2">Coming Soon</h3>
              <p className="text-sm text-muted-foreground max-w-sm">
                Comments moderation functionality will be implemented here. You&apos;ll be able to
                review, approve, hide, or delete comments that violate community guidelines.
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
}

export default function CommentsModerationPage() {
  return (
    <ProtectedRoute requireAuth>
      <CommentsModerationContent />
    </ProtectedRoute>
  );
}
