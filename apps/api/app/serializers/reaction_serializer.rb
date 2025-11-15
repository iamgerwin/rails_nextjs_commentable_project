# frozen_string_literal: true

# Reaction serializer for API responses
class ReactionSerializer < ActiveModel::Serializer
  attributes :id, :type_name, :reactable_type, :reactable_id,
             :created_at, :updated_at

  belongs_to :user, serializer: UserSerializer

  # Include reactable entity if requested
  def reactable
    return unless instance_options[:include_reactable]

    case object.reactable_type
    when 'Video'
      VideoSerializer.new(object.reactable).as_json
    when 'Post'
      PostSerializer.new(object.reactable).as_json
    when 'Comment'
      CommentSerializer.new(object.reactable).as_json
    end
  end
end
