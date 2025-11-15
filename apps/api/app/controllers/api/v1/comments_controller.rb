# frozen_string_literal: true

module Api
  module V1
    # Comments controller with Ransack filtering and nested routes support
    # Supports commenting on Videos and Posts with nested replies
    #
    # Ransack Examples:
    #   GET /api/v1/comments?q[content_cont]=great
    #   GET /api/v1/comments?q[status_eq]=active&q[commentable_type_eq]=Video
    #   GET /api/v1/comments?q[user_username_cont]=john
    #   GET /api/v1/comments?q[parent_id_null]=true&q[s]=created_at desc
    #   GET /api/v1/comments?q[created_at_gteq]=2024-01-01
    #
    # Nested Routes:
    #   GET /api/v1/videos/:video_id/comments
    #   POST /api/v1/videos/:video_id/comments
    #   GET /api/v1/posts/:post_id/comments
    #   POST /api/v1/posts/:post_id/comments
    #   POST /api/v1/comments/:id/replies (nested reply)
    #
    class CommentsController < BaseController
      before_action :authenticate_user!, except: [:index, :show]
      before_action :authenticate_user, only: [:index, :show]
      before_action :set_commentable, only: [:index, :create], if: -> { params[:video_id] || params[:post_id] }
      before_action :set_comment, only: [:show, :update, :destroy, :replies]
      before_action :authorize_comment, only: [:update, :destroy]

      # GET /api/v1/comments
      # GET /api/v1/videos/:video_id/comments
      # GET /api/v1/posts/:post_id/comments
      # List comments with Ransack filtering
      def index
        base_scope = @commentable ? @commentable.comments : Comment.all

        # Apply authorization scope
        @q = policy_scope(base_scope).ransack(params[:q])
        @comments = @q.result(distinct: true)
                      .includes(:user, :parent)
                      .page(pagination_params[:page])
                      .per(pagination_params[:per_page])

        render_success(
          ActiveModel::Serializer::CollectionSerializer.new(
            @comments,
            serializer: CommentSerializer
          ).as_json,
          meta: pagination_meta(@comments)
        )
      end

      # GET /api/v1/comments/:id
      # Show single comment with optional nested replies
      def show
        authorize @comment

        unless @comment.viewable_by?(current_user)
          return render_forbidden('You do not have permission to view this comment')
        end

        render_success(
          CommentSerializer.new(
            @comment,
            include_replies: params[:include_replies] == 'true'
          ).as_json
        )
      end

      # POST /api/v1/videos/:video_id/comments
      # POST /api/v1/posts/:post_id/comments
      # Create a new comment on a commentable entity
      def create
        unless @commentable
          return render_error(
            'Commentable entity not found',
            code: 'COMMENTABLE_NOT_FOUND',
            status: :not_found
          )
        end

        @comment = @commentable.comments.build(comment_params)
        @comment.user = current_user

        if @comment.save
          AuditLog.log_create(@comment, user: current_user)
          render_success(
            CommentSerializer.new(@comment).as_json,
            status: :created
          )
        else
          render_error(
            @comment.errors.full_messages.join(', '),
            code: 'COMMENT_CREATE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # POST /api/v1/comments/:id/replies
      # Create a nested reply to a comment
      def replies
        authorize @comment, :reply?

        unless @comment.can_reply?(current_user)
          return render_forbidden('You cannot reply to this comment')
        end

        @reply = @comment.replies.build(reply_params)
        @reply.user = current_user
        @reply.commentable = @comment.commentable

        if @reply.save
          AuditLog.log_create(@reply, user: current_user)
          render_success(
            CommentSerializer.new(@reply).as_json,
            status: :created
          )
        else
          render_error(
            @reply.errors.full_messages.join(', '),
            code: 'REPLY_CREATE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # PATCH/PUT /api/v1/comments/:id
      # Update comment
      def update
        if @comment.update(comment_params)
          AuditLog.log_update(@comment, user: current_user)
          render_success(CommentSerializer.new(@comment).as_json)
        else
          render_error(
            @comment.errors.full_messages.join(', '),
            code: 'COMMENT_UPDATE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # DELETE /api/v1/comments/:id
      # Soft delete comment
      def destroy
        if @comment.destroy
          AuditLog.log_delete(@comment, user: current_user)
          render_success({ message: 'Comment deleted successfully' })
        else
          render_error(
            'Failed to delete comment',
            code: 'COMMENT_DELETE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      private

      def set_commentable
        if params[:video_id]
          @commentable = Video.find(params[:video_id])
        elsif params[:post_id]
          # Support both ID and slug for posts
          @commentable = if params[:post_id].match?(/^\d+$/) || params[:post_id].match?(/^[0-9a-f]{8}-/)
                           Post.find(params[:post_id])
                         else
                           Post.find_by!(slug: params[:post_id])
                         end
        end
      rescue ActiveRecord::RecordNotFound
        render_error(
          'Commentable entity not found',
          code: 'COMMENTABLE_NOT_FOUND',
          status: :not_found
        )
      end

      def set_comment
        @comment = Comment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error(
          'Comment not found',
          code: 'COMMENT_NOT_FOUND',
          status: :not_found
        )
      end

      def authorize_comment
        authorize @comment
      end

      def comment_params
        params.require(:comment).permit(:content, :status)
      end

      def reply_params
        params.require(:comment).permit(:content)
      end
    end
  end
end
