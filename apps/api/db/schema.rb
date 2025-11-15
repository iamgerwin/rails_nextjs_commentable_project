# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_15_174040) do
  create_table "audit_logs", id: :string, force: :cascade do |t|
    t.string "action", null: false
    t.string "auditable_id", null: false
    t.string "auditable_type", null: false
    t.json "change_data", default: {}
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.json "metadata", default: {}
    t.text "user_agent"
    t.string "user_id"
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "comments", id: :string, force: :cascade do |t|
    t.string "commentable_id", null: false
    t.string "commentable_type", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "parent_id"
    t.integer "reactions_count", default: 0, null: false
    t.integer "replies_count", default: 0, null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.string "user_id", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["created_at"], name: "index_comments_on_created_at"
    t.index ["deleted_at"], name: "index_comments_on_deleted_at"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["status"], name: "index_comments_on_status"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "posts", id: :string, force: :cascade do |t|
    t.integer "comments_count", default: 0, null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.text "excerpt"
    t.string "featured_image_url"
    t.json "metadata", default: {}
    t.datetime "published_at"
    t.integer "reactions_count", default: 0, null: false
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.json "tags", default: []
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "user_id", null: false
    t.integer "views_count", default: 0, null: false
    t.string "visibility", default: "private", null: false
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["deleted_at"], name: "index_posts_on_deleted_at"
    t.index ["published_at"], name: "index_posts_on_published_at"
    t.index ["slug"], name: "index_posts_on_slug", unique: true, where: "deleted_at IS NULL"
    t.index ["status", "visibility", "published_at"], name: "index_posts_on_status_and_visibility_and_published_at"
    t.index ["status"], name: "index_posts_on_status"
    t.index ["user_id"], name: "index_posts_on_user_id"
    t.index ["visibility"], name: "index_posts_on_visibility"
  end

  create_table "reactions", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "reactable_id", null: false
    t.string "reactable_type", null: false
    t.string "type_name", null: false
    t.datetime "updated_at", null: false
    t.string "user_id", null: false
    t.index ["reactable_type", "reactable_id"], name: "index_reactions_on_reactable_type_and_reactable_id"
    t.index ["type_name"], name: "index_reactions_on_type_name"
    t.index ["user_id", "reactable_type", "reactable_id", "type_name"], name: "index_reactions_on_user_and_reactable_and_type", unique: true
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "reports", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "reason", null: false
    t.string "reportable_id", null: false
    t.string "reportable_type", null: false
    t.string "reporter_id", null: false
    t.text "resolution"
    t.datetime "reviewed_at"
    t.string "reviewer_id"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_reports_on_created_at"
    t.index ["reason"], name: "index_reports_on_reason"
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable_type_and_reportable_id"
    t.index ["reporter_id"], name: "index_reports_on_reporter_id"
    t.index ["reviewer_id"], name: "index_reports_on_reviewer_id"
    t.index ["status"], name: "index_reports_on_status"
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.string "avatar"
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email", null: false
    t.string "email_verification_token"
    t.boolean "email_verified", default: false, null: false
    t.datetime "email_verified_at"
    t.string "first_name", null: false
    t.datetime "last_login_at"
    t.string "last_login_ip"
    t.string "last_name", null: false
    t.string "password_digest", null: false
    t.datetime "password_reset_sent_at"
    t.string "password_reset_token"
    t.string "role", default: "user", null: false
    t.integer "sign_in_count", default: 0
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true, where: "deleted_at IS NULL"
    t.index ["email_verification_token"], name: "index_users_on_email_verification_token", unique: true
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["status"], name: "index_users_on_status"
    t.index ["username"], name: "index_users_on_username", unique: true, where: "deleted_at IS NULL"
  end

  create_table "videos", id: :string, force: :cascade do |t|
    t.integer "comments_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.text "description"
    t.integer "duration", default: 0, null: false
    t.json "metadata", default: {}
    t.datetime "published_at"
    t.integer "reactions_count", default: 0, null: false
    t.string "status", default: "draft", null: false
    t.json "tags", default: []
    t.string "thumbnail_url"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.string "user_id", null: false
    t.integer "views_count", default: 0, null: false
    t.string "visibility", default: "private", null: false
    t.index ["created_at"], name: "index_videos_on_created_at"
    t.index ["deleted_at"], name: "index_videos_on_deleted_at"
    t.index ["published_at"], name: "index_videos_on_published_at"
    t.index ["status", "visibility", "published_at"], name: "index_videos_on_status_and_visibility_and_published_at"
    t.index ["status"], name: "index_videos_on_status"
    t.index ["user_id"], name: "index_videos_on_user_id"
    t.index ["visibility"], name: "index_videos_on_visibility"
  end

  add_foreign_key "audit_logs", "users", on_delete: :nullify
  add_foreign_key "comments", "comments", column: "parent_id", on_delete: :cascade
  add_foreign_key "comments", "users", on_delete: :cascade
  add_foreign_key "posts", "users", on_delete: :cascade
  add_foreign_key "reactions", "users", on_delete: :cascade
  add_foreign_key "reports", "users", column: "reporter_id", on_delete: :cascade
  add_foreign_key "reports", "users", column: "reviewer_id", on_delete: :nullify
  add_foreign_key "videos", "users", on_delete: :cascade
end
