# frozen_string_literal: true

# Create videos table
# Videos represent video content with metadata and engagement tracking
class CreateVideos < ActiveRecord::Migration[8.1]
  def change
    create_table :videos, id: :string do |t|
      # Associations
      t.string :user_id, null: false

      # Content
      t.string :title, null: false
      t.text :description
      t.string :url, null: false
      t.string :thumbnail_url

      # Metadata
      t.integer :duration, null: false, default: 0 # in seconds
      t.string :status, null: false, default: 'draft'
      t.string :visibility, null: false, default: 'private'

      # Tags and custom metadata (JSON)
      t.json :tags, default: []
      t.json :metadata, default: {}

      # Counter caches (to avoid N+1 queries)
      t.integer :views_count, default: 0, null: false
      t.integer :comments_count, default: 0, null: false
      t.integer :reactions_count, default: 0, null: false

      # Publishing
      t.datetime :published_at

      # Timestamps
      t.timestamps

      # Soft delete
      t.datetime :deleted_at
    end

    # Foreign keys
    add_foreign_key :videos, :users, on_delete: :cascade

    # Indexes
    add_index :videos, :user_id
    add_index :videos, :status
    add_index :videos, :visibility
    add_index :videos, :published_at
    add_index :videos, :created_at
    add_index :videos, :deleted_at
    add_index :videos, [:status, :visibility, :published_at]
  end
end
