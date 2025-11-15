'use client';

import { ProtectedRoute } from '@/components/auth/protected-route';
import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { MessageSquare } from 'lucide-react';

function MyCommentsContent() {
  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">My Comments</h2>
          <p className="text-muted-foreground">
            View and manage your comments
          </p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <MessageSquare className="h-5 w-5" />
              Your Comments
            </CardTitle>
            <CardDescription>
              View all comments you&apos;ve made across the platform
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <MessageSquare className="h-12 w-12 text-muted-foreground mb-4" />
              <h3 className="text-lg font-semibold mb-2">No Comments Yet</h3>
              <p className="text-sm text-muted-foreground max-w-sm">
                You haven&apos;t made any comments yet. Start engaging with the community by
                commenting on videos and blog posts.
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
}

export default function MyCommentsPage() {
  return (
    <ProtectedRoute requireAuth>
      <MyCommentsContent />
    </ProtectedRoute>
  );
}
