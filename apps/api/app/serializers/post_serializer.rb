# frozen_string_literal: true

# Post serializer for API responses
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :excerpt, :slug, :featured_image_url,
             :status, :visibility, :tags, :metadata,
             :views_count, :comments_count, :reactions_count, :reading_time,
             :published_at, :created_at, :updated_at

  belongs_to :user, serializer: UserSerializer

  # Option to exclude content for list views
  def content
    object.content unless instance_options[:exclude_content]
  end
end
