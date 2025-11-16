'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { videosService } from '@/services/videos.service';
import { Video, VideoVisibility, VideoStatus } from '@workspace/shared-types';
import { ArrowLeft, Save, Upload } from 'lucide-react';

interface VideoFormProps {
  video?: Video;
  mode: 'create' | 'edit';
}

export function VideoForm({ video, mode }: VideoFormProps) {
  const router = useRouter();
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [formData, setFormData] = useState({
    title: video?.title || '',
    description: video?.description || '',
    url: video?.url || '',
    thumbnailUrl: video?.thumbnailUrl || '',
    duration: video?.duration || 0,
    visibility: video?.visibility || VideoVisibility.PUBLIC,
    tags: video?.tags?.join(', ') || '',
  });

  const handleChange = (field: string, value: string | number) => {
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

      const videoData = {
        title: formData.title,
        description: formData.description,
        url: formData.url,
        thumbnailUrl: formData.thumbnailUrl,
        duration: formData.duration,
        visibility: formData.visibility,
        tags: tagsArray,
      };

      const response =
        mode === 'create'
          ? await videosService.createVideo(videoData)
          : await videosService.updateVideo(video!.id, videoData);

      if (response.success && response.data) {
        router.push(`/videos/${response.data.id}`);
      } else {
        setError('Failed to save video');
      }
    } catch (err) {
      console.error('Failed to save video:', err);
      setError('An error occurred while saving the video');
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
              {mode === 'create' ? 'Create Video' : 'Update Video'}
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
            placeholder="Enter video title"
            value={formData.title}
            onChange={(e) => handleChange('title', e.target.value)}
            required
          />
        </div>

        {/* Description */}
        <div className="space-y-2">
          <Label htmlFor="description">Description</Label>
          <Textarea
            id="description"
            placeholder="Enter video description"
            value={formData.description}
            onChange={(e) => handleChange('description', e.target.value)}
            className="min-h-[120px]"
          />
        </div>

        {/* Video URL */}
        <div className="space-y-2">
          <Label htmlFor="url">
            Video URL <span className="text-destructive">*</span>
          </Label>
          <Input
            id="url"
            type="url"
            placeholder="https://example.com/video.mp4"
            value={formData.url}
            onChange={(e) => handleChange('url', e.target.value)}
            required
          />
          <p className="text-sm text-muted-foreground">
            Enter the direct URL to the video file
          </p>
        </div>

        {/* Thumbnail URL */}
        <div className="space-y-2">
          <Label htmlFor="thumbnailUrl">Thumbnail URL</Label>
          <Input
            id="thumbnailUrl"
            type="url"
            placeholder="https://example.com/thumbnail.jpg"
            value={formData.thumbnailUrl}
            onChange={(e) => handleChange('thumbnailUrl', e.target.value)}
          />
        </div>

        {/* Duration */}
        <div className="space-y-2">
          <Label htmlFor="duration">
            Duration (seconds) <span className="text-destructive">*</span>
          </Label>
          <Input
            id="duration"
            type="number"
            min="0"
            placeholder="0"
            value={formData.duration}
            onChange={(e) => handleChange('duration', parseInt(e.target.value) || 0)}
            required
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
              <SelectItem value={VideoVisibility.PUBLIC}>Public</SelectItem>
              <SelectItem value={VideoVisibility.UNLISTED}>Unlisted</SelectItem>
              <SelectItem value={VideoVisibility.PRIVATE}>Private</SelectItem>
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
              {mode === 'create' ? <Upload className="mr-2 h-4 w-4" /> : <Save className="mr-2 h-4 w-4" />}
              {mode === 'create' ? 'Create Video' : 'Update Video'}
            </>
          )}
        </Button>
      </div>
    </form>
  );
}
