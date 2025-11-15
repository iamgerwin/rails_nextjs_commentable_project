# frozen_string_literal: true

module Videos
  # Action to update an existing video
  # Handles video updates with authorization checks and audit logging
  class UpdateAction < BaseAction
    attr_reader :video, :user, :params

    validates :video, :user, presence: true
    validate :user_can_edit_video

    def initialize(video:, user:, params:, **_options)
      @video = video
      @user = user
      @params = params
      super()
    end

    protected

    def perform
      if video.update(video_params)
        success(value: video)
      else
        failure(errors: video.errors.full_messages)
      end
    end

    def should_audit?
      success?
    end

    def log_audit_trail
      AuditLog.log_update(
        @value,
        user: user,
        metadata: { controller: 'Api::V1::VideosController', action: 'update' }
      )
    end

    private

    def video_params
      params.permit(:title, :description, :url, :thumbnail_url, :duration, :status, :visibility, tags: [], metadata: {})
    end

    def user_can_edit_video
      return if video.editable_by?(user)

      errors.add(:base, 'You are not authorized to edit this video')
    end
  end
end
