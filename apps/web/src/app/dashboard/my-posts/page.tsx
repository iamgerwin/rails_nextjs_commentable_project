'use client';

import { ProtectedRoute } from '@/components/auth/protected-route';
import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { FileText, Plus } from 'lucide-react';

function MyPostsContent() {
  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-3xl font-bold tracking-tight">My Posts</h2>
            <p className="text-muted-foreground">
              Manage your blog posts
            </p>
          </div>
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            Create Post
          </Button>
        </div>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <FileText className="h-5 w-5" />
              Your Posts
            </CardTitle>
            <CardDescription>
              View and manage posts you&apos;ve created
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <FileText className="h-12 w-12 text-muted-foreground mb-4" />
              <h3 className="text-lg font-semibold mb-2">No Posts Yet</h3>
              <p className="text-sm text-muted-foreground max-w-sm mb-4">
                You haven&apos;t created any blog posts yet. Start by writing your first post to
                share your thoughts with the community.
              </p>
              <Button>
                <Plus className="mr-2 h-4 w-4" />
                Write Your First Post
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
}

export default function MyPostsPage() {
  return (
    <ProtectedRoute requireAuth>
      <MyPostsContent />
    </ProtectedRoute>
  );
}
