# frozen_string_literal: true

# Create reactions table
# Reactions are polymorphic - they can belong to Videos, Posts, or Comments
# Types: like, dislike, love, clap
class CreateReactions < ActiveRecord::Migration[8.1]
  def change
    create_table :reactions, id: :string do |t|
      # Associations
      t.string :user_id, null: false

      # Polymorphic association (reactable: Video, Post, or Comment)
      t.string :reactable_type, null: false
      t.string :reactable_id, null: false

      # Reaction type
      t.string :type_name, null: false # 'like', 'dislike', 'love', 'clap'

      # Timestamps
      t.timestamps
    end

    # Foreign keys
    add_foreign_key :reactions, :users, on_delete: :cascade

    # Indexes
    add_index :reactions, :user_id
    add_index :reactions, [:reactable_type, :reactable_id]
    add_index :reactions, :type_name

    # Unique constraint: one user can only create one reaction of each type per item
    add_index :reactions, [:user_id, :reactable_type, :reactable_id, :type_name],
              unique: true,
              name: 'index_reactions_on_user_and_reactable_and_type'
  end
end
