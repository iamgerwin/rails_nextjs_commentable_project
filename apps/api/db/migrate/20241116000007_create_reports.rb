# frozen_string_literal: true

# Create reports table
# Reports are polymorphic - they can report Videos, Posts, Comments, or Users
class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports, id: :string do |t|
      # Reporter (who created the report)
      t.string :reporter_id, null: false

      # Reviewer (who is reviewing/has reviewed the report)
      t.string :reviewer_id

      # Polymorphic association (reportable: Video, Post, Comment, or User)
      t.string :reportable_type, null: false
      t.string :reportable_id, null: false

      # Report details
      t.string :reason, null: false # spam, harassment, inappropriate, etc.
      t.text :description

      # Status workflow
      t.string :status, null: false, default: 'pending'

      # Resolution
      t.text :resolution
      t.datetime :reviewed_at

      # Timestamps
      t.timestamps
    end

    # Foreign keys
    add_foreign_key :reports, :users, column: :reporter_id, on_delete: :cascade
    add_foreign_key :reports, :users, column: :reviewer_id, on_delete: :nullify

    # Indexes
    add_index :reports, :reporter_id
    add_index :reports, :reviewer_id
    add_index :reports, [:reportable_type, :reportable_id]
    add_index :reports, :status
    add_index :reports, :reason
    add_index :reports, :created_at
  end
end
