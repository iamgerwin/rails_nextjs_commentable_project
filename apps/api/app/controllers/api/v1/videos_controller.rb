# frozen_string_literal: true

module Api
  module V1
    # Videos controller with Ransack filtering and sorting
    # Supports advanced search, pagination, and authorization
    #
    # Ransack Examples:
    #   GET /api/v1/videos?q[title_cont]=rails
    #   GET /api/v1/videos?q[status_eq]=published&q[visibility_eq]=public
    #   GET /api/v1/videos?q[created_at_gteq]=2024-01-01&q[s]=created_at desc
    #   GET /api/v1/videos?q[user_username_cont]=john&q[tags_cont]=tutorial
    #
    class VideosController < BaseController
      before_action :authenticate_user!, except: [:index, :show]
      before_action :authenticate_user, only: [:index, :show]
      before_action :set_video, only: [:show, :update, :destroy, :publish, :archive]
      before_action :authorize_video, only: [:update, :destroy, :publish, :archive]

      # GET /api/v1/videos
      # List videos with Ransack filtering
      #
      # Ransack Predicates:
      #   - eq: equals
      #   - cont: contains (case-insensitive)
      #   - start: starts with
      #   - end: ends with
      #   - gt/lt: greater/less than
      #   - gteq/lteq: greater/less than or equal
      #   - in: in array
      #
      # Sort:
      #   - q[s]=created_at desc
      #   - q[s]=views_count desc
      #   - q[s]=title asc
      #
      def index
        @q = policy_scope(Video).ransack(params[:q])
        @videos = @q.result(distinct: true)
                    .includes(:user)
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

      # GET /api/v1/videos/:id
      # Show single video
      def show
        authorize @video

        unless @video.viewable_by?(current_user)
          return render_forbidden('You do not have permission to view this video')
        end

        # Increment view count asynchronously
        # IncrementViewCountJob.perform_later(@video.id)
        @video.increment_views!

        render_success(
          VideoSerializer.new(@video, include_reactions: true).as_json
        )
      end

      # POST /api/v1/videos
      # Create a new video
      def create
        result = Videos::CreateAction.call(
          user: current_user,
          params: video_params
        )

        if result.success?
          render_success(
            VideoSerializer.new(result.value).as_json,
            status: :created
          )
        else
          render_error(
            result.error_messages,
            code: 'VIDEO_CREATE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # PATCH/PUT /api/v1/videos/:id
      # Update video
      def update
        result = Videos::UpdateAction.call(
          video: @video,
          user: current_user,
          params: video_params
        )

        if result.success?
          render_success(VideoSerializer.new(result.value).as_json)
        else
          render_error(
            result.error_messages,
            code: 'VIDEO_UPDATE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # DELETE /api/v1/videos/:id
      # Soft delete video
      def destroy
        if @video.destroy
          render_success({ message: 'Video deleted successfully' })
        else
          render_error(
            'Failed to delete video',
            code: 'VIDEO_DELETE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # POST /api/v1/videos/:id/publish
      # Publish a video
      def publish
        if @video.may_publish?
          @video.publish!
          render_success(
            VideoSerializer.new(@video).as_json,
            meta: { message: 'Video published successfully' }
          )
        else
          render_error(
            "Cannot publish video from #{@video.status} status",
            code: 'INVALID_STATE_TRANSITION',
            status: :unprocessable_entity
          )
        end
      end

      # POST /api/v1/videos/:id/archive
      # Archive a video
      def archive
        if @video.may_archive?
          @video.archive!
          render_success(
            VideoSerializer.new(@video).as_json,
            meta: { message: 'Video archived successfully' }
          )
        else
          render_error(
            "Cannot archive video from #{@video.status} status",
            code: 'INVALID_STATE_TRANSITION',
            status: :unprocessable_entity
          )
        end
      end

      private

      def set_video
        @video = Video.find(params[:id])
      end

      def authorize_video
        authorize @video
      end

      def video_params
        params.require(:video).permit(
          :title, :description, :url, :thumbnail_url, :duration,
          :status, :visibility,
          tags: [],
          metadata: {}
        )
      end
    end
  end
end
