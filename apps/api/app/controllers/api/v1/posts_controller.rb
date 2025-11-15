# frozen_string_literal: true

module Api
  module V1
    # Posts controller with Ransack filtering and sorting
    #
    # Ransack Examples:
    #   GET /api/v1/posts?q[title_or_content_cont]=rails
    #   GET /api/v1/posts?q[status_eq]=published&q[visibility_eq]=public
    #   GET /api/v1/posts?q[tags_cont]=tutorial&q[s]=published_at desc
    #   GET /api/v1/posts?q[user_username_eq]=john
    #
    class PostsController < BaseController
      before_action :authenticate_user!, except: [:index, :show]
      before_action :authenticate_user, only: [:index, :show]
      before_action :set_post, only: [:show, :update, :destroy, :publish, :archive]
      before_action :authorize_post, only: [:update, :destroy, :publish, :archive]

      # GET /api/v1/posts
      # List posts with Ransack filtering
      def index
        @q = policy_scope(Post).ransack(params[:q])
        @posts = @q.result(distinct: true)
                   .includes(:user)
                   .page(pagination_params[:page])
                   .per(pagination_params[:per_page])

        render_success(
          ActiveModel::Serializer::CollectionSerializer.new(
            @posts,
            serializer: PostSerializer,
            exclude_content: true # Don't include full content in list view
          ).as_json,
          meta: pagination_meta(@posts)
        )
      end

      # GET /api/v1/posts/:id
      # Show single post (supports both ID and slug)
      def show
        authorize @post

        unless @post.viewable_by?(current_user)
          return render_forbidden('You do not have permission to view this post')
        end

        @post.increment_views!

        render_success(
          PostSerializer.new(@post).as_json
        )
      end

      # POST /api/v1/posts
      # Create a new post
      def create
        @post = current_user.posts.build(post_params)

        if @post.save
          AuditLog.log_create(@post, user: current_user)
          render_success(
            PostSerializer.new(@post).as_json,
            status: :created
          )
        else
          render_error(
            @post.errors.full_messages.join(', '),
            code: 'POST_CREATE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # PATCH/PUT /api/v1/posts/:id
      # Update post
      def update
        if @post.update(post_params)
          AuditLog.log_update(@post, user: current_user)
          render_success(PostSerializer.new(@post).as_json)
        else
          render_error(
            @post.errors.full_messages.join(', '),
            code: 'POST_UPDATE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # DELETE /api/v1/posts/:id
      # Soft delete post
      def destroy
        if @post.destroy
          AuditLog.log_delete(@post, user: current_user)
          render_success({ message: 'Post deleted successfully' })
        else
          render_error(
            'Failed to delete post',
            code: 'POST_DELETE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # POST /api/v1/posts/:id/publish
      # Publish a post
      def publish
        if @post.may_publish?
          @post.publish!
          AuditLog.log_update(@post, user: current_user)
          render_success(
            PostSerializer.new(@post).as_json,
            meta: { message: 'Post published successfully' }
          )
        else
          render_error(
            "Cannot publish post from #{@post.status} status",
            code: 'INVALID_STATE_TRANSITION',
            status: :unprocessable_entity
          )
        end
      end

      # POST /api/v1/posts/:id/archive
      # Archive a post
      def archive
        if @post.may_archive?
          @post.archive!
          AuditLog.log_update(@post, user: current_user)
          render_success(
            PostSerializer.new(@post).as_json,
            meta: { message: 'Post archived successfully' }
          )
        else
          render_error(
            "Cannot archive post from #{@post.status} status",
            code: 'INVALID_STATE_TRANSITION',
            status: :unprocessable_entity
          )
        end
      end

      private

      def set_post
        # Support both ID and slug lookups
        @post = if params[:id].match?(/^\d+$/) || params[:id].match?(/^[0-9a-f]{8}-/)
                  Post.find(params[:id])
                else
                  Post.find_by!(slug: params[:id])
                end
      end

      def authorize_post
        authorize @post, :update?
      end

      def post_params
        params.require(:post).permit(
          :title, :content, :excerpt, :featured_image_url,
          :status, :visibility,
          tags: [],
          metadata: {}
        )
      end
    end
  end
end
