# frozen_string_literal: true

# Video serializer for API responses
class VideoSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :url, :thumbnail_url, :duration,
             :status, :visibility, :tags, :metadata,
             :views_count, :comments_count, :reactions_count,
             :published_at, :created_at, :updated_at

  belongs_to :user, serializer: UserSerializer

  # Include reaction summary if requested
  def reaction_summary
    object.reaction_summary if instance_options[:include_reactions]
  end
end
