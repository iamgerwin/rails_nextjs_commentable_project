'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import { ProtectedRoute } from '@/components/auth/protected-route';
import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { PostForm } from '@/components/forms/post-form';
import { postsService } from '@/services/posts.service';
import { Post } from '@workspace/shared-types';

function EditPostContent() {
  const params = useParams();
  const postId = params.id as string;
  const [post, setPost] = useState<Post | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (postId) {
      fetchPost();
    }
  }, [postId]);

  const fetchPost = async () => {
    try {
      const response = await postsService.getPost(postId);
      if (response.success && response.data) {
        setPost(response.data);
      }
    } catch (error) {
      console.error('Failed to fetch post:', error);
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

  if (!post) {
    return (
      <DashboardLayout>
        <div className="text-center py-12">
          <h2 className="text-2xl font-bold">Post not found</h2>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Edit Post</h2>
          <p className="text-muted-foreground">
            Update post content and settings
          </p>
        </div>

        <PostForm mode="edit" post={post} />
      </div>
    </DashboardLayout>
  );
}

export default function EditPostPage() {
  return (
    <ProtectedRoute requireAuth>
      <EditPostContent />
    </ProtectedRoute>
  );
}
