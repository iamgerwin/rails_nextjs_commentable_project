# frozen_string_literal: true

# Create comments table
# Comments are polymorphic - they can belong to Videos or Posts
# They also support nested replies (self-referential)
class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments, id: :string do |t|
      # Associations
      t.string :user_id, null: false

      # Polymorphic association (commentable: Video or Post)
      t.string :commentable_type, null: false
      t.string :commentable_id, null: false

      # Self-referential for nested replies
      t.string :parent_id

      # Content
      t.text :content, null: false

      # Status
      t.string :status, null: false, default: 'active'

      # Counter caches
      t.integer :replies_count, default: 0, null: false
      t.integer :reactions_count, default: 0, null: false

      # Timestamps
      t.timestamps

      # Soft delete
      t.datetime :deleted_at
    end

    # Foreign keys
    add_foreign_key :comments, :users, on_delete: :cascade
    add_foreign_key :comments, :comments, column: :parent_id, on_delete: :cascade

    # Indexes
    add_index :comments, :user_id
    add_index :comments, [:commentable_type, :commentable_id]
    add_index :comments, :parent_id
    add_index :comments, :status
    add_index :comments, :created_at
    add_index :comments, :deleted_at
  end
end
