# frozen_string_literal: true

module Api
  module V1
    # Users controller with Ransack filtering and user profile management
    #
    # Ransack Examples:
    #   GET /api/v1/users?q[username_cont]=john
    #   GET /api/v1/users?q[role_eq]=moderator
    #   GET /api/v1/users?q[status_eq]=active
    #   GET /api/v1/users?q[email_verified_eq]=true
    #   GET /api/v1/users?q[created_at_gteq]=2024-01-01&q[s]=created_at desc
    #   GET /api/v1/users?q[first_name_or_last_name_cont]=smith
    #
    class UsersController < BaseController
      before_action :authenticate_user!, except: [:index, :show]
      before_action :authenticate_user, only: [:index, :show]
      before_action :set_user, only: [:show, :update, :destroy, :profile, :videos, :posts, :comments]
      before_action :authorize_user, only: [:update, :destroy]

      # GET /api/v1/users
      # List users with Ransack filtering
      def index
        @q = policy_scope(User).ransack(params[:q])
        @users = @q.result(distinct: true)
                   .page(pagination_params[:page])
                   .per(pagination_params[:per_page])

        render_success(
          ActiveModel::Serializer::CollectionSerializer.new(
            @users,
            serializer: UserSerializer,
            scope: current_user
          ).as_json,
          meta: pagination_meta(@users)
        )
      end

      # GET /api/v1/users/:id
      # Show user profile (supports both ID and username)
      def show
        authorize @user

        render_success(
          UserSerializer.new(@user, scope: current_user).as_json
        )
      end

      # GET /api/v1/users/:id/profile
      # Get detailed user profile with stats
      def profile
        authorize @user, :show?

        profile_data = UserSerializer.new(@user, scope: current_user).as_json
        profile_data[:statistics] = {
          videos_count: @user.videos.count,
          posts_count: @user.posts.count,
          comments_count: @user.comments.count,
          reactions_given: @user.reactions.count,
          total_views: @user.videos.sum(:views_count) + @user.posts.sum(:views_count)
        }

        render_success(profile_data)
      end

      # GET /api/v1/users/:id/videos
      # Get user's videos with filtering
      def videos
        authorize @user, :show?

        @q = policy_scope(@user.videos).ransack(params[:q])
        @videos = @q.result(distinct: true)
                    .page(pagination_params[:page])
                    .per(pagination_params[:per_page])

        render_success(
          ActiveModel::Serializer::CollectionSerializer.new(
            @videos,
            serializer: VideoSerializer
          ).as_json,
          meta: pagination_meta(@videos)
        )
      end

      # GET /api/v1/users/:id/posts
      # Get user's posts with filtering
      def posts
        authorize @user, :show?

        @q = policy_scope(@user.posts).ransack(params[:q])
        @posts = @q.result(distinct: true)
                   .page(pagination_params[:page])
                   .per(pagination_params[:per_page])

        render_success(
          ActiveModel::Serializer::CollectionSerializer.new(
            @posts,
            serializer: PostSerializer,
            exclude_content: true
          ).as_json,
          meta: pagination_meta(@posts)
        )
      end

      # GET /api/v1/users/:id/comments
      # Get user's comments with filtering
      def comments
        authorize @user, :show?

        @q = policy_scope(@user.comments).ransack(params[:q])
        @comments = @q.result(distinct: true)
                      .includes(:commentable)
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

      # PATCH/PUT /api/v1/users/:id
      # Update user profile
      def update
        if @user.update(user_params)
          AuditLog.log_update(@user, user: current_user)
          render_success(
            UserSerializer.new(@user, scope: current_user).as_json
          )
        else
          render_error(
            @user.errors.full_messages.join(', '),
            code: 'USER_UPDATE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # DELETE /api/v1/users/:id
      # Soft delete user account
      def destroy
        if @user.destroy
          AuditLog.log_delete(@user, user: current_user)
          render_success({ message: 'User account deleted successfully' })
        else
          render_error(
            'Failed to delete user account',
            code: 'USER_DELETE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      private

      def set_user
        # Support both ID and username lookups
        @user = if params[:id].match?(/^\d+$/) || params[:id].match?(/^[0-9a-f]{8}-/)
                  User.find(params[:id])
                else
                  User.find_by!(username: params[:id])
                end
      rescue ActiveRecord::RecordNotFound
        render_error(
          'User not found',
          code: 'USER_NOT_FOUND',
          status: :not_found
        )
      end

      def authorize_user
        authorize @user
      end

      def user_params
        params.require(:user).permit(
          :username, :first_name, :last_name, :bio, :avatar,
          :email, :password, :password_confirmation
        )
      end
    end
  end
end
