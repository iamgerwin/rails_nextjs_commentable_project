'use client';

import { useState, useEffect } from 'react';
import { ProtectedRoute } from '@/components/auth/protected-route';
import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { DataTable, DataTableColumn } from '@/components/data-table';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from '@/components/ui/dropdown-menu';
import { commentsService } from '@/services/comments.service';
import { Comment, CommentStatus } from '@workspace/shared-types';
import { MoreVertical, Eye, Check, EyeOff, Trash2, MessageSquare } from 'lucide-react';

function CommentsModerationContent() {
  const [comments, setComments] = useState<Comment[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [searchQuery, setSearchQuery] = useState('');

  const perPage = 10;

  useEffect(() => {
    fetchComments();
  }, [page, searchQuery]);

  const fetchComments = async () => {
    setLoading(true);
    try {
      const response = await commentsService.getComments({
        page,
        perPage,
      });

      if (response.success && response.data) {
        if (Array.isArray(response.data)) {
          setComments(response.data);
          setTotalPages(1);
          setTotalCount(response.data.length);
        } else if (response.data.data && Array.isArray(response.data.data)) {
          setComments(response.data.data);
          setTotalPages(response.data.meta?.totalPages || 1);
          setTotalCount(response.data.meta?.totalCount || response.data.data.length);
        } else if (response.meta) {
          setComments(Array.isArray(response.data) ? response.data : []);
          setTotalPages((response.meta.totalPages as number) || 1);
          setTotalCount((response.meta.totalCount as number) || 0);
        } else {
          setComments([]);
          setTotalPages(1);
          setTotalCount(0);
        }
      }
    } catch (error) {
      console.error('Failed to fetch comments:', error);
      setComments([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    setPage(1);
  };

  const handleUpdateStatus = async (commentId: string, status: CommentStatus) => {
    try {
      const response = await commentsService.updateComment(commentId, { status });
      if (response.success) {
        fetchComments();
      }
    } catch (error) {
      console.error('Failed to update comment status:', error);
    }
  };

  const handleDelete = async (commentId: string) => {
    if (!confirm('Are you sure you want to delete this comment?')) return;

    try {
      const response = await commentsService.deleteComment(commentId);
      if (response.success) {
        fetchComments();
      }
    } catch (error) {
      console.error('Failed to delete comment:', error);
    }
  };

  const getStatusBadge = (status: CommentStatus) => {
    const variants: Record<CommentStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      [CommentStatus.ACTIVE]: 'default',
      [CommentStatus.HIDDEN]: 'outline',
      [CommentStatus.DELETED]: 'secondary',
      [CommentStatus.FLAGGED]: 'destructive',
    };

    return <Badge variant={variants[status]}>{status}</Badge>;
  };

  const columns: DataTableColumn<Comment>[] = [
    {
      key: 'content',
      header: 'Comment',
      render: (comment) => (
        <div className="max-w-md">
          <div className="font-medium text-sm line-clamp-2">{comment.content}</div>
          {comment.user && (
            <div className="text-xs text-muted-foreground mt-1">by {comment.user.username}</div>
          )}
        </div>
      ),
    },
    {
      key: 'commentable',
      header: 'Target',
      render: (comment) => (
        <div className="text-sm">
          <div className="font-medium">{comment.commentableType}</div>
          {comment.commentable && 'title' in comment.commentable && (
            <div className="text-xs text-muted-foreground line-clamp-1">
              {comment.commentable.title}
            </div>
          )}
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      sortable: true,
      render: (comment) => getStatusBadge(comment.status),
    },
    {
      key: 'repliesCount',
      header: 'Replies',
      sortable: true,
      render: (comment) => (
        <div className="flex items-center gap-1">
          <MessageSquare className="h-4 w-4 text-muted-foreground" />
          <span>{comment.repliesCount}</span>
        </div>
      ),
    },
    {
      key: 'reactionsCount',
      header: 'Reactions',
      sortable: true,
    },
    {
      key: 'createdAt',
      header: 'Posted',
      sortable: true,
      render: (comment) => new Date(comment.createdAt).toLocaleDateString(),
    },
  ];

  const renderActions = (comment: Comment) => (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="sm">
          <MoreVertical className="h-4 w-4" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuItem>
          <Eye className="mr-2 h-4 w-4" />
          View Comment
        </DropdownMenuItem>
        {comment.status !== CommentStatus.ACTIVE && (
          <DropdownMenuItem onClick={() => handleUpdateStatus(comment.id, CommentStatus.ACTIVE)}>
            <Check className="mr-2 h-4 w-4" />
            Approve
          </DropdownMenuItem>
        )}
        {comment.status !== CommentStatus.HIDDEN && (
          <DropdownMenuItem onClick={() => handleUpdateStatus(comment.id, CommentStatus.HIDDEN)}>
            <EyeOff className="mr-2 h-4 w-4" />
            Hide
          </DropdownMenuItem>
        )}
        <DropdownMenuItem
          className="text-destructive"
          onClick={() => handleDelete(comment.id)}
        >
          <Trash2 className="mr-2 h-4 w-4" />
          Delete Comment
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-3xl font-bold tracking-tight">Comments Moderation</h2>
            <p className="text-muted-foreground">
              Moderate and manage comments across the platform
            </p>
          </div>
        </div>

        <DataTable
          data={comments}
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
          searchPlaceholder="Search comments..."
          emptyMessage="No comments found"
          actions={renderActions}
        />
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
