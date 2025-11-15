# frozen_string_literal: true

# Report serializer for API responses
class ReportSerializer < ActiveModel::Serializer
  attributes :id, :reason, :description, :status, :reportable_type, :reportable_id,
             :reviewed_at, :resolved_at, :moderator_notes,
             :created_at, :updated_at

  belongs_to :reporter, serializer: UserSerializer
  belongs_to :moderator, serializer: UserSerializer, if: -> { object.moderator.present? }

  # Include reportable entity if requested
  def reportable
    return unless instance_options[:include_reportable]

    case object.reportable_type
    when 'Video'
      VideoSerializer.new(object.reportable).as_json
    when 'Post'
      PostSerializer.new(object.reportable).as_json
    when 'Comment'
      CommentSerializer.new(object.reportable).as_json
    when 'User'
      UserSerializer.new(object.reportable).as_json
    end
  end

  # Hide moderator notes from non-moderators
  def moderator_notes
    return unless scope&.can_moderate?
    object.moderator_notes
  end
end
