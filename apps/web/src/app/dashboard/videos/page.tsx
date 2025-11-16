'use client';

import { useState, useEffect } from 'react';
import { ProtectedRoute } from '@/components/auth/protected-route';
import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { DataTable, DataTableColumn } from '@/components/data-table';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from '@/components/ui/dropdown-menu';
import { videosService } from '@/services/videos.service';
import { Video as VideoType, VideoStatus, VideoVisibility } from '@workspace/shared-types';
import { Plus, MoreVertical, Edit, Trash2, Eye, Play } from 'lucide-react';

function VideosManagementContent() {
  const [videos, setVideos] = useState<VideoType[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [searchQuery, setSearchQuery] = useState('');

  const perPage = 10;

  useEffect(() => {
    fetchVideos();
  }, [page, searchQuery]);

  const fetchVideos = async () => {
    setLoading(true);
    try {
      const response = await videosService.getVideos({
        page,
        perPage,
        search: searchQuery || undefined,
      });

      if (response.success && response.data) {
        if (Array.isArray(response.data)) {
          setVideos(response.data);
          setTotalPages(1);
          setTotalCount(response.data.length);
        } else if (response.data.data && Array.isArray(response.data.data)) {
          setVideos(response.data.data);
          setTotalPages(response.data.meta?.totalPages || 1);
          setTotalCount(response.data.meta?.totalCount || response.data.data.length);
        } else if (response.meta) {
          setVideos(Array.isArray(response.data) ? response.data : []);
          setTotalPages(response.meta.totalPages || 1);
          setTotalCount(response.meta.totalCount || 0);
        } else {
          setVideos([]);
          setTotalPages(1);
          setTotalCount(0);
        }
      }
    } catch (error) {
      console.error('Failed to fetch videos:', error);
      setVideos([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    setPage(1);
  };

  const handleDelete = async (videoId: string) => {
    if (!confirm('Are you sure you want to delete this video?')) return;

    try {
      const response = await videosService.deleteVideo(videoId);
      if (response.success) {
        fetchVideos();
      }
    } catch (error) {
      console.error('Failed to delete video:', error);
    }
  };

  const getStatusBadge = (status: VideoStatus) => {
    const variants: Record<VideoStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      [VideoStatus.DRAFT]: 'secondary',
      [VideoStatus.PUBLISHED]: 'default',
      [VideoStatus.ARCHIVED]: 'outline',
    };

    return <Badge variant={variants[status]}>{status}</Badge>;
  };

  const getVisibilityBadge = (visibility: VideoVisibility) => {
    const variants: Record<VideoVisibility, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      [VideoVisibility.PUBLIC]: 'default',
      [VideoVisibility.PRIVATE]: 'secondary',
      [VideoVisibility.UNLISTED]: 'outline',
    };

    return <Badge variant={variants[visibility]}>{visibility}</Badge>;
  };

  const formatDuration = (seconds: number) => {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${minutes}:${secs.toString().padStart(2, '0')}`;
  };

  const columns: DataTableColumn<VideoType>[] = [
    {
      key: 'thumbnail',
      header: '',
      render: (video) => (
        <div className="w-20 h-12 bg-muted rounded overflow-hidden flex items-center justify-center">
          {video.thumbnailUrl ? (
            <img src={video.thumbnailUrl} alt={video.title} className="w-full h-full object-cover" />
          ) : (
            <Play className="h-6 w-6 text-muted-foreground" />
          )}
        </div>
      ),
    },
    {
      key: 'title',
      header: 'Title',
      sortable: true,
      render: (video) => (
        <div>
          <div className="font-medium">{video.title}</div>
          {video.user && (
            <div className="text-sm text-muted-foreground">by {video.user.username}</div>
          )}
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      sortable: true,
      render: (video) => getStatusBadge(video.status),
    },
    {
      key: 'visibility',
      header: 'Visibility',
      sortable: true,
      render: (video) => getVisibilityBadge(video.visibility),
    },
    {
      key: 'duration',
      header: 'Duration',
      render: (video) => formatDuration(video.duration),
    },
    {
      key: 'viewsCount',
      header: 'Views',
      sortable: true,
    },
    {
      key: 'createdAt',
      header: 'Uploaded',
      sortable: true,
      render: (video) => new Date(video.createdAt).toLocaleDateString(),
    },
  ];

  const renderActions = (video: VideoType) => (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="sm">
          <MoreVertical className="h-4 w-4" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuItem>
          <Eye className="mr-2 h-4 w-4" />
          View Video
        </DropdownMenuItem>
        <DropdownMenuItem>
          <Edit className="mr-2 h-4 w-4" />
          Edit Video
        </DropdownMenuItem>
        <DropdownMenuItem
          className="text-destructive"
          onClick={() => handleDelete(video.id)}
        >
          <Trash2 className="mr-2 h-4 w-4" />
          Delete Video
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-3xl font-bold tracking-tight">All Videos</h2>
            <p className="text-muted-foreground">
              Manage all videos across the platform
            </p>
          </div>
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            Upload Video
          </Button>
        </div>

        <DataTable
          data={videos}
          columns={columns}
          loading={loading}
          pagination={{
            currentPage: page,
            totalPages,
            totalCount,
            perPage,
          }}
          onPageChange={setPage}
          onSearch={handleSearch}
          searchPlaceholder="Search videos by title..."
          emptyMessage="No videos found"
          actions={renderActions}
        />
      </div>
    </DashboardLayout>
  );
}

export default function VideosManagementPage() {
  return (
    <ProtectedRoute requireAuth>
      <VideosManagementContent />
    </ProtectedRoute>
  );
}
