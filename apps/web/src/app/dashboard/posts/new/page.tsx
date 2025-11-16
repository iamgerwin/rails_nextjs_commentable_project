'use client';

import { ProtectedRoute } from '@/components/auth/protected-route';
import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { PostForm } from '@/components/forms/post-form';

function NewPostContent() {
  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Create New Post</h2>
          <p className="text-muted-foreground">
            Write a new blog post or article
          </p>
        </div>

        <PostForm mode="create" />
      </div>
    </DashboardLayout>
  );
}

export default function NewPostPage() {
  return (
    <ProtectedRoute requireAuth>
      <NewPostContent />
    </ProtectedRoute>
  );
}
