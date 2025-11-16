'use client';

import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Avatar } from '@/components/ui/avatar';
import { ReactionButtons } from '@/components/reactions';
import { commentsService } from '@/services/comments.service';
import { Comment, CommentableType } from '@workspace/shared-types';
import { MessageSquare, Send, Reply } from 'lucide-react';
import { useAuth } from '@/contexts/auth-context';

interface CommentSectionProps {
  commentableType: CommentableType;
  commentableId: string;
  initialComments?: Comment[];
}

interface CommentItemProps {
  comment: Comment;
  commentableType: CommentableType;
  commentableId: string;
  onReplySubmit: () => void;
}

function CommentItem({ comment, commentableType, commentableId, onReplySubmit }: CommentItemProps) {
  const [showReplyForm, setShowReplyForm] = useState(false);
  const [replyContent, setReplyContent] = useState('');
  const [submittingReply, setSubmittingReply] = useState(false);
  const [showReplies, setShowReplies] = useState(false);
  const { user } = useAuth();

  const handleReplySubmit = async () => {
    if (!replyContent.trim() || submittingReply) return;

    setSubmittingReply(true);
    try {
      const response = await commentsService.createReply(comment.id, replyContent);
      if (response.success) {
        setReplyContent('');
        setShowReplyForm(false);
        onReplySubmit();
      }
    } catch (error) {
      console.error('Failed to submit reply:', error);
    } finally {
      setSubmittingReply(false);
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex gap-3">
        <Avatar className="h-10 w-10">
          {comment.user?.avatar ? (
            <img src={comment.user.avatar} alt={comment.user.username} />
          ) : (
            <div className="flex h-full w-full items-center justify-center bg-muted">
              <span className="text-sm font-medium">{comment.user?.initials || '?'}</span>
            </div>
          )}
        </Avatar>

        <div className="flex-1 space-y-2">
          <div>
            <div className="flex items-center gap-2">
              <span className="font-semibold text-sm">{comment.user?.username || 'Unknown'}</span>
              <span className="text-xs text-muted-foreground">
                {new Date(comment.createdAt).toLocaleDateString()}
              </span>
            </div>
            <p className="text-sm mt-1 whitespace-pre-wrap">{comment.content}</p>
          </div>

          <div className="flex items-center gap-4">
            <ReactionButtons
              reactableType="Comment"
              reactableId={comment.id}
              size="sm"
              showCounts={true}
            />

            {user && (
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setShowReplyForm(!showReplyForm)}
                className="gap-2"
              >
                <Reply className="h-3 w-3" />
                Reply
              </Button>
            )}

            {comment.repliesCount > 0 && (
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setShowReplies(!showReplies)}
                className="gap-2"
              >
                <MessageSquare className="h-3 w-3" />
                {comment.repliesCount} {comment.repliesCount === 1 ? 'reply' : 'replies'}
              </Button>
            )}
          </div>

          {showReplyForm && (
            <div className="flex gap-2 mt-2">
              <Textarea
                placeholder="Write a reply..."
                value={replyContent}
                onChange={(e) => setReplyContent(e.target.value)}
                className="min-h-[60px]"
              />
              <div className="flex flex-col gap-2">
                <Button
                  size="sm"
                  onClick={handleReplySubmit}
                  disabled={!replyContent.trim() || submittingReply}
                >
                  <Send className="h-3 w-3" />
                </Button>
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => {
                    setShowReplyForm(false);
                    setReplyContent('');
                  }}
                >
                  Cancel
                </Button>
              </div>
            </div>
          )}

          {showReplies && comment.replies && comment.replies.length > 0 && (
            <div className="ml-6 space-y-4 mt-4 border-l-2 border-muted pl-4">
              {comment.replies.map((reply) => (
                <CommentItem
                  key={reply.id}
                  comment={reply}
                  commentableType={commentableType}
                  commentableId={commentableId}
                  onReplySubmit={onReplySubmit}
                />
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export function CommentSection({
  commentableType,
  commentableId,
  initialComments,
}: CommentSectionProps) {
  const [comments, setComments] = useState<Comment[]>(initialComments || []);
  const [newComment, setNewComment] = useState('');
  const [loading, setLoading] = useState(!initialComments);
  const [submitting, setSubmitting] = useState(false);
  const { user } = useAuth();

  useEffect(() => {
    if (!initialComments) {
      fetchComments();
    }
  }, [commentableId, commentableType]);

  const fetchComments = async () => {
    setLoading(true);
    try {
      const response = await commentsService.getCommentableComments(
        commentableType,
        commentableId,
        { parentId: null } // Only fetch top-level comments
      );

      if (response.success && response.data) {
        const data = Array.isArray(response.data)
          ? response.data
          : response.data.data
          ? response.data.data
          : [];
        setComments(data);
      }
    } catch (error) {
      console.error('Failed to fetch comments:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async () => {
    if (!newComment.trim() || submitting) return;

    setSubmitting(true);
    try {
      const response =
        commentableType === 'Video'
          ? await commentsService.createVideoComment(commentableId, newComment)
          : await commentsService.createPostComment(commentableId, newComment);

      if (response.success) {
        setNewComment('');
        await fetchComments();
      }
    } catch (error) {
      console.error('Failed to submit comment:', error);
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="space-y-4">
        <div className="h-8 w-48 bg-muted animate-pulse rounded" />
        <div className="h-32 bg-muted animate-pulse rounded" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2">
        <MessageSquare className="h-5 w-5" />
        <h3 className="text-lg font-semibold">
          {comments.length} {comments.length === 1 ? 'Comment' : 'Comments'}
        </h3>
      </div>

      {user ? (
        <div className="space-y-2">
          <Textarea
            placeholder="Add a comment..."
            value={newComment}
            onChange={(e) => setNewComment(e.target.value)}
            className="min-h-[100px]"
          />
          <div className="flex justify-end">
            <Button
              onClick={handleSubmit}
              disabled={!newComment.trim() || submitting}
              className="gap-2"
            >
              <Send className="h-4 w-4" />
              {submitting ? 'Posting...' : 'Post Comment'}
            </Button>
          </div>
        </div>
      ) : (
        <div className="text-sm text-muted-foreground p-4 border rounded-md">
          Please sign in to comment
        </div>
      )}

      <div className="space-y-6">
        {comments.length === 0 ? (
          <div className="text-center text-muted-foreground py-8">
            No comments yet. Be the first to comment!
          </div>
        ) : (
          comments.map((comment) => (
            <CommentItem
              key={comment.id}
              comment={comment}
              commentableType={commentableType}
              commentableId={commentableId}
              onReplySubmit={fetchComments}
            />
          ))
        )}
      </div>
    </div>
  );
}
