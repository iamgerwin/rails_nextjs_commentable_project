'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { postsService } from '@/services/posts.service';
import { Post, PostVisibility } from '@workspace/shared-types';
import { ArrowLeft, Save, FileText } from 'lucide-react';

interface PostFormProps {
  post?: Post;
  mode: 'create' | 'edit';
}

export function PostForm({ post, mode }: PostFormProps) {
  const router = useRouter();
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [formData, setFormData] = useState({
    title: post?.title || '',
    content: post?.content || '',
    excerpt: post?.excerpt || '',
    featuredImageUrl: post?.featuredImageUrl || '',
    visibility: post?.visibility || PostVisibility.PUBLIC,
    tags: post?.tags?.join(', ') || '',
  });

  const handleChange = (field: string, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setError(null);

    try {
      const tagsArray = formData.tags
        .split(',')
        .map((tag) => tag.trim())
        .filter((tag) => tag.length > 0);

      const postData = {
        title: formData.title,
        content: formData.content,
        excerpt: formData.excerpt,
        featuredImageUrl: formData.featuredImageUrl,
        visibility: formData.visibility,
        tags: tagsArray,
      };

      const response =
        mode === 'create'
          ? await postsService.createPost(postData)
          : await postsService.updatePost(post!.id, postData);

      if (response.success && response.data) {
        router.push(`/posts/${response.data.id}`);
      } else {
        setError('Failed to save post');
      }
    } catch (err) {
      console.error('Failed to save post:', err);
      setError('An error occurred while saving the post');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="flex items-center justify-between">
        <Button type="button" variant="ghost" onClick={() => router.back()}>
          <ArrowLeft className="mr-2 h-4 w-4" />
          Back
        </Button>
        <Button type="submit" disabled={submitting}>
          {submitting ? (
            'Saving...'
          ) : (
            <>
              <Save className="mr-2 h-4 w-4" />
              {mode === 'create' ? 'Create Post' : 'Update Post'}
            </>
          )}
        </Button>
      </div>

      {error && (
        <div className="bg-destructive/10 text-destructive px-4 py-3 rounded-md">
          {error}
        </div>
      )}

      <div className="grid gap-6">
        {/* Title */}
        <div className="space-y-2">
          <Label htmlFor="title">
            Title <span className="text-destructive">*</span>
          </Label>
          <Input
            id="title"
            placeholder="Enter post title"
            value={formData.title}
            onChange={(e) => handleChange('title', e.target.value)}
            required
          />
        </div>

        {/* Excerpt */}
        <div className="space-y-2">
          <Label htmlFor="excerpt">Excerpt</Label>
          <Textarea
            id="excerpt"
            placeholder="Brief summary or teaser"
            value={formData.excerpt}
            onChange={(e) => handleChange('excerpt', e.target.value)}
            className="min-h-[80px]"
          />
          <p className="text-sm text-muted-foreground">
            A short summary that appears in listings
          </p>
        </div>

        {/* Content */}
        <div className="space-y-2">
          <Label htmlFor="content">
            Content <span className="text-destructive">*</span>
          </Label>
          <Textarea
            id="content"
            placeholder="Write your post content here..."
            value={formData.content}
            onChange={(e) => handleChange('content', e.target.value)}
            className="min-h-[400px] font-mono"
            required
          />
          <p className="text-sm text-muted-foreground">
            Full content of your post (supports plain text and markdown)
          </p>
        </div>

        {/* Featured Image URL */}
        <div className="space-y-2">
          <Label htmlFor="featuredImageUrl">Featured Image URL</Label>
          <Input
            id="featuredImageUrl"
            type="url"
            placeholder="https://example.com/image.jpg"
            value={formData.featuredImageUrl}
            onChange={(e) => handleChange('featuredImageUrl', e.target.value)}
          />
        </div>

        {/* Visibility */}
        <div className="space-y-2">
          <Label htmlFor="visibility">Visibility</Label>
          <Select
            value={formData.visibility}
            onValueChange={(value) => handleChange('visibility', value)}
          >
            <SelectTrigger id="visibility">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value={PostVisibility.PUBLIC}>Public</SelectItem>
              <SelectItem value={PostVisibility.UNLISTED}>Unlisted</SelectItem>
              <SelectItem value={PostVisibility.PRIVATE}>Private</SelectItem>
            </SelectContent>
          </Select>
        </div>

        {/* Tags */}
        <div className="space-y-2">
          <Label htmlFor="tags">Tags</Label>
          <Input
            id="tags"
            placeholder="tag1, tag2, tag3"
            value={formData.tags}
            onChange={(e) => handleChange('tags', e.target.value)}
          />
          <p className="text-sm text-muted-foreground">
            Separate tags with commas
          </p>
        </div>
      </div>

      <div className="flex justify-end gap-3 pt-6 border-t">
        <Button type="button" variant="outline" onClick={() => router.back()}>
          Cancel
        </Button>
        <Button type="submit" disabled={submitting}>
          {submitting ? (
            'Saving...'
          ) : (
            <>
              {mode === 'create' ? <FileText className="mr-2 h-4 w-4" /> : <Save className="mr-2 h-4 w-4" />}
              {mode === 'create' ? 'Create Post' : 'Update Post'}
            </>
          )}
        </Button>
      </div>
    </form>
  );
}
