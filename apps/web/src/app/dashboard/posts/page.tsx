'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { ProtectedRoute } from '@/components/auth/protected-route';
import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { DataTable, DataTableColumn } from '@/components/data-table';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from '@/components/ui/dropdown-menu';
import { postsService } from '@/services/posts.service';
import { Post, PostStatus, PostVisibility } from '@workspace/shared-types';
import { Plus, MoreVertical, Edit, Trash2, Eye, FileText } from 'lucide-react';

function PostsManagementContent() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [searchQuery, setSearchQuery] = useState('');

  const perPage = 10;

  useEffect(() => {
    fetchPosts();
  }, [page, searchQuery]);

  const fetchPosts = async () => {
    setLoading(true);
    try {
      const response = await postsService.getPosts({
        page,
        perPage,
        search: searchQuery || undefined,
      });

      if (response.success && response.data) {
        if (Array.isArray(response.data)) {
          setPosts(response.data);
          setTotalPages(1);
          setTotalCount(response.data.length);
        } else if (response.data.data && Array.isArray(response.data.data)) {
          setPosts(response.data.data);
          setTotalPages(response.data.meta?.totalPages || 1);
          setTotalCount(response.data.meta?.totalCount || response.data.data.length);
        } else if (response.meta) {
          setPosts(Array.isArray(response.data) ? response.data : []);
          setTotalPages(response.meta.totalPages || 1);
          setTotalCount(response.meta.totalCount || 0);
        } else {
          setPosts([]);
          setTotalPages(1);
          setTotalCount(0);
        }
      }
    } catch (error) {
      console.error('Failed to fetch posts:', error);
      setPosts([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    setPage(1);
  };

  const handleDelete = async (postId: string) => {
    if (!confirm('Are you sure you want to delete this post?')) return;

    try {
      const response = await postsService.deletePost(postId);
      if (response.success) {
        fetchPosts();
      }
    } catch (error) {
      console.error('Failed to delete post:', error);
    }
  };

  const getStatusBadge = (status: PostStatus) => {
    const variants: Record<PostStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      [PostStatus.DRAFT]: 'secondary',
      [PostStatus.PUBLISHED]: 'default',
      [PostStatus.ARCHIVED]: 'outline',
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

  const columns: DataTableColumn<Post>[] = [
    {
      key: 'featuredImage',
      header: '',
      render: (post) => (
        <div className="w-20 h-12 bg-muted rounded overflow-hidden flex items-center justify-center">
          {post.featuredImageUrl ? (
            <img src={post.featuredImageUrl} alt={post.title} className="w-full h-full object-cover" />
          ) : (
            <FileText className="h-6 w-6 text-muted-foreground" />
          )}
        </div>
      ),
    },
    {
      key: 'title',
      header: 'Title',
      sortable: true,
      render: (post) => (
        <div>
          <div className="font-medium">{post.title}</div>
          {post.user && (
            <div className="text-sm text-muted-foreground">by {post.user.username}</div>
          )}
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      sortable: true,
      render: (post) => getStatusBadge(post.status),
    },
    {
      key: 'visibility',
      header: 'Visibility',
      sortable: true,
      render: (post) => getVisibilityBadge(post.visibility),
    },
    {
      key: 'viewsCount',
      header: 'Views',
      sortable: true,
    },
    {
      key: 'commentsCount',
      header: 'Comments',
      sortable: true,
    },
    {
      key: 'createdAt',
      header: 'Published',
      sortable: true,
      render: (post) => new Date(post.createdAt).toLocaleDateString(),
    },
  ];

  const renderActions = (post: Post) => (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="sm">
          <MoreVertical className="h-4 w-4" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuItem asChild>
          <Link href={`/posts/${post.id}`} className="cursor-pointer">
            <Eye className="mr-2 h-4 w-4" />
            View Post
          </Link>
        </DropdownMenuItem>
        <DropdownMenuItem asChild>
          <Link href={`/dashboard/posts/${post.id}/edit`} className="cursor-pointer">
            <Edit className="mr-2 h-4 w-4" />
            Edit Post
          </Link>
        </DropdownMenuItem>
        <DropdownMenuItem
          className="text-destructive"
          onClick={() => handleDelete(post.id)}
        >
          <Trash2 className="mr-2 h-4 w-4" />
          Delete Post
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-3xl font-bold tracking-tight">All Posts</h2>
            <p className="text-muted-foreground">
              Manage all blog posts across the platform
            </p>
          </div>
          <Button asChild>
            <Link href="/dashboard/posts/new">
              <Plus className="mr-2 h-4 w-4" />
              Create Post
            </Link>
          </Button>
        </div>

        <DataTable
          data={posts}
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
          searchPlaceholder="Search posts by title..."
          emptyMessage="No posts found"
          actions={renderActions}
        />
      </div>
    </DashboardLayout>
  );
}

export default function PostsManagementPage() {
  return (
    <ProtectedRoute requireAuth>
      <PostsManagementContent />
    </ProtectedRoute>
  );
}
