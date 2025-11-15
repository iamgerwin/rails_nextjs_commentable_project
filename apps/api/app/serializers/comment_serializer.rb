# frozen_string_literal: true

# Comment serializer for API responses
class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content, :status, :commentable_type, :commentable_id,
             :parent_id, :replies_count, :reactions_count,
             :created_at, :updated_at, :deleted_at

  belongs_to :user, serializer: UserSerializer
  belongs_to :parent, serializer: CommentSerializer, if: -> { object.parent.present? }

  # Include nested replies if requested
  has_many :replies, serializer: CommentSerializer, if: -> { instance_options[:include_replies] }

  # Include commentable entity if requested
  def commentable
    case object.commentable_type
    when 'Video'
      VideoSerializer.new(object.commentable).as_json
    when 'Post'
      PostSerializer.new(object.commentable).as_json
    end
  end

  # Show deleted_at only if soft deleted
  def deleted_at
    object.deleted_at if object.deleted?
  end
end
