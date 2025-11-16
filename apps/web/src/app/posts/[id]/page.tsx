'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { ReactionButtons } from '@/components/reactions';
import { CommentSection } from '@/components/comments';
import { postsService } from '@/services/posts.service';
import { Post, PostStatus, PostVisibility, ReactableType, CommentableType } from '@workspace/shared-types';
import { ArrowLeft, Eye, Calendar, User, Clock } from 'lucide-react';

export default function PostDetailPage() {
  const params = useParams();
  const router = useRouter();
  const postId = params.id as string;

  const [post, setPost] = useState<Post | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (postId) {
      fetchPost();
    }
  }, [postId]);

  const fetchPost = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await postsService.getPost(postId);
      if (response.success && response.data) {
        setPost(response.data);
      } else {
        setError('Post not found');
      }
    } catch (err) {
      console.error('Failed to fetch post:', err);
      setError('Failed to load post');
    } finally {
      setLoading(false);
    }
  };

  const getStatusBadge = (status: PostStatus) => {
    const variants: Record<PostStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      [PostStatus.DRAFT]: 'secondary',
      [PostStatus.PUBLISHED]: 'default',
      [PostStatus.ARCHIVED]: 'outline',
      [PostStatus.DELETED]: 'destructive',
    };

    return <Badge variant={variants[status]}>{status}</Badge>;
  };

  const getVisibilityBadge = (visibility: PostVisibility) => {
    const variants: Record<PostVisibility, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      [PostVisibility.PUBLIC]: 'default',
      [PostVisibility.PRIVATE]: 'secondary',
      [PostVisibility.UNLISTED]: 'outline',
    };

    return <Badge variant={variants[visibility]}>{visibility}</Badge>;
  };

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto space-y-6">
          <div className="h-8 w-32 bg-muted animate-pulse rounded" />
          <div className="h-12 w-3/4 bg-muted animate-pulse rounded" />
          <div className="h-64 bg-muted animate-pulse rounded" />
          <div className="space-y-4">
            <div className="h-4 bg-muted animate-pulse rounded" />
            <div className="h-4 bg-muted animate-pulse rounded" />
            <div className="h-4 w-2/3 bg-muted animate-pulse rounded" />
          </div>
        </div>
      </div>
    );
  }

  if (error || !post) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-2xl font-bold mb-4">{error || 'Post not found'}</h1>
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
      <div className="max-w-4xl mx-auto space-y-6">
        {/* Back Button */}
        <Button variant="ghost" onClick={() => router.back()}>
          <ArrowLeft className="mr-2 h-4 w-4" />
          Back
        </Button>

        {/* Post Header */}
        <article className="space-y-6">
          {/* Featured Image */}
          {post.featuredImageUrl && (
            <div className="relative aspect-video rounded-lg overflow-hidden">
              <img
                src={post.featuredImageUrl}
                alt={post.title}
                className="w-full h-full object-cover"
              />
            </div>
          )}

          {/* Title and Meta */}
          <div className="space-y-4">
            <div className="flex items-start justify-between gap-4">
              <h1 className="text-4xl font-bold flex-1">{post.title}</h1>
              <div className="flex gap-2">
                {getStatusBadge(post.status)}
                {getVisibilityBadge(post.visibility)}
              </div>
            </div>

            <div className="flex flex-wrap items-center gap-4 text-sm text-muted-foreground">
              {post.user && (
                <div className="flex items-center gap-1">
                  <User className="h-4 w-4" />
                  <span>{post.user.username}</span>
                </div>
              )}
              <div className="flex items-center gap-1">
                <Calendar className="h-4 w-4" />
                <span>{new Date(post.createdAt).toLocaleDateString()}</span>
              </div>
              <div className="flex items-center gap-1">
                <Eye className="h-4 w-4" />
                <span>{post.viewsCount} views</span>
              </div>
              {post.readingTime && (
                <div className="flex items-center gap-1">
                  <Clock className="h-4 w-4" />
                  <span>{post.readingTime} min read</span>
                </div>
              )}
            </div>

            {/* Excerpt */}
            {post.excerpt && (
              <p className="text-lg text-muted-foreground italic border-l-4 border-primary pl-4">
                {post.excerpt}
              </p>
            )}
          </div>

          {/* Content */}
          <div className="prose prose-lg max-w-none">
            <div className="whitespace-pre-wrap">{post.content}</div>
          </div>

          {/* Tags */}
          {post.tags && post.tags.length > 0 && (
            <div className="flex flex-wrap gap-2">
              {post.tags.map((tag, index) => (
                <Badge key={index} variant="outline">
                  #{tag}
                </Badge>
              ))}
            </div>
          )}

          {/* Reactions */}
          <div className="border-y py-4">
            <ReactionButtons reactableType={ReactableType.POST} reactableId={post.id} showCounts={true} />
          </div>

          {/* Comments */}
          <div className="pt-6">
            <CommentSection commentableType={CommentableType.POST} commentableId={post.id} />
          </div>
        </article>
      </div>
    </div>
  );
}
