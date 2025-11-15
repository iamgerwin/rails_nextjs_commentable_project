# frozen_string_literal: true

module Videos
  # Action to create a new video
  # Handles video creation with proper authorization and audit logging
  class CreateAction < BaseAction
    attr_reader :user, :params

    validates :user, presence: true
    validate :valid_video_params

    def initialize(user:, params:, **_options)
      @user = user
      @params = params
      super()
    end

    protected

    def perform
      video = user.videos.build(video_params)

      if video.save
        # Queue background job for video processing
        # ProcessVideoJob.perform_later(video.id)

        success(value: video)
      else
        failure(errors: video.errors.full_messages)
      end
    end

    def should_audit?
      success?
    end

    def log_audit_trail
      AuditLog.log_create(
        @value,
        user: user,
        metadata: { controller: 'Api::V1::VideosController', action: 'create' }
      )
    end

    private

    def video_params
      params.permit(:title, :description, :url, :thumbnail_url, :duration, :visibility, tags: [], metadata: {})
    end

    def valid_video_params
      errors.add(:params, 'must include title') unless params[:title].present?
      errors.add(:params, 'must include url') unless params[:url].present?
    end
  end
end
