# frozen_string_literal: true

# Create posts table
# Posts represent blog posts and articles with rich content
class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts, id: :string do |t|
      # Associations
      t.string :user_id, null: false

      # Content
      t.string :title, null: false
      t.text :content, null: false
      t.text :excerpt
      t.string :slug, null: false

      # Images
      t.string :featured_image_url

      # Metadata
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
    add_foreign_key :posts, :users, on_delete: :cascade

    # Indexes
    add_index :posts, :user_id
    add_index :posts, :slug, unique: true, where: 'deleted_at IS NULL'
    add_index :posts, :status
    add_index :posts, :visibility
    add_index :posts, :published_at
    add_index :posts, :created_at
    add_index :posts, :deleted_at
    add_index :posts, [:status, :visibility, :published_at]
  end
end
