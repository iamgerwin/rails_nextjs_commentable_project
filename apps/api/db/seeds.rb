# frozen_string_literal: true

# Database Seeding for Rails Next.js Commentable Project
# This file is idempotent and can be run multiple times
# Run with: rails db:seed

puts '🌱 Starting database seeding...'

# Helper to conditionally seed
def seed_data?
  Rails.env.development? || Rails.env.test? || ENV['SEED_PRODUCTION'] == 'true'
end

unless seed_data?
  puts '⚠️  Skipping seeds in production (set SEED_PRODUCTION=true to override)'
  exit
end

# =============================================================================
# USERS - Sample users for each role
# =============================================================================

puts "\n👥 Creating sample users..."

# Admin User (email: admin@example.com, password: admin@example.com)
admin = User.find_or_create_by!(email: 'admin@example.com') do |u|
  u.username = 'admin'
  u.password = 'admin@example.com'
  u.password_confirmation = 'admin@example.com'
  u.first_name = 'Admin'
  u.last_name = 'User'
  u.role = 'admin'
  u.status = 'active'
  u.email_verified = true
  u.email_verified_at = Time.current
  u.bio = 'System administrator with full access to all features and settings.'
  u.avatar = 'https://i.pravatar.cc/150?img=1'
end
puts "  ✓ Admin: #{admin.email}"

# Moderator User (email: moderator@example.com, password: moderator@example.com)
moderator = User.find_or_create_by!(email: 'moderator@example.com') do |u|
  u.username = 'moderator'
  u.password = 'moderator@example.com'
  u.password_confirmation = 'moderator@example.com'
  u.first_name = 'Moderator'
  u.last_name = 'User'
  u.role = 'moderator'
  u.status = 'active'
  u.email_verified = true
  u.email_verified_at = Time.current
  u.bio = 'Content moderator responsible for reviewing reports and managing community.'
  u.avatar = 'https://i.pravatar.cc/150?img=2'
end
puts "  ✓ Moderator: #{moderator.email}"

# Regular User (email: user@example.com, password: user@example.com)
regular_user = User.find_or_create_by!(email: 'user@example.com') do |u|
  u.username = 'user'
  u.password = 'user@example.com'
  u.password_confirmation = 'user@example.com'
  u.first_name = 'Regular'
  u.last_name = 'User'
  u.role = 'user'
  u.status = 'active'
  u.email_verified = true
  u.email_verified_at = Time.current
  u.bio = 'Standard user account with access to public features.'
  u.avatar = 'https://i.pravatar.cc/150?img=3'
end
puts "  ✓ User: #{regular_user.email}"

# Additional sample users
sample_users = []
if Rails.env.development?
  puts "\n  Creating additional sample users..."
  10.times do |i|
    user = User.find_or_create_by!(email: "user#{i + 1}@example.com") do |u|
      u.username = "user#{i + 1}"
      u.password = 'password123'
      u.password_confirmation = 'password123'
      u.first_name = Faker::Name.first_name
      u.last_name = Faker::Name.last_name
      u.role = 'user'
      u.status = 'active'
      u.email_verified = true
      u.email_verified_at = Time.current
      u.bio = Faker::Lorem.paragraph(sentence_count: 2)
      u.avatar = "https://i.pravatar.cc/150?img=#{i + 10}"
    end
    sample_users << user
  end
  puts "  ✓ Created #{sample_users.count} additional users"
end

all_users = [admin, moderator, regular_user] + sample_users

# =============================================================================
# VIDEOS - Sample video content
# =============================================================================

if Rails.env.development?
  puts "\n🎥 Creating sample videos..."

  video_titles = [
    'Introduction to Ruby on Rails 8',
    'Building REST APIs with Rails',
    'Next.js 16 App Router Tutorial',
    'TypeScript Best Practices',
    'Database Design Fundamentals',
    'Authentication with JWT',
    'React Hooks Deep Dive',
    'SQL vs NoSQL Databases',
    'DevOps for Beginners',
    'Clean Code Principles'
  ]

  videos = []
  video_titles.each_with_index do |title, i|
    user = all_users.sample
    video = Video.find_or_create_by!(title: title, user: user) do |v|
      v.description = Faker::Lorem.paragraph(sentence_count: 5)
      v.url = "https://example.com/videos/video-#{i + 1}.mp4"
      v.thumbnail_url = "https://picsum.photos/1280/720?random=#{i + 1}"
      v.duration = Faker::Number.between(from: 300, to: 3600)
      v.status = ['draft', 'published', 'published', 'published'].sample
      v.visibility = ['public', 'public', 'public', 'unlisted', 'private'].sample
      v.tags = ['tutorial', 'programming', 'tech'].sample(2)
      v.metadata = {
        resolution: '1080p',
        fps: 30,
        codec: 'h264'
      }
      v.views_count = Faker::Number.between(from: 10, to: 5000)
      v.published_at = v.status == 'published' ? Faker::Time.between(from: 30.days.ago, to: Time.current) : nil
    end
    videos << video
  end
  puts "  ✓ Created #{videos.count} videos"
end

# =============================================================================
# POSTS - Sample blog posts
# =============================================================================

if Rails.env.development?
  puts "\n📝 Creating sample posts..."

  post_titles = [
    'Getting Started with Monorepo Development',
    'The Future of Web Development in 2024',
    'Microservices vs Monoliths: A Practical Guide',
    'Understanding REST API Design',
    'Database Optimization Techniques',
    'The Art of Code Review',
    'Continuous Integration Best Practices',
    'Security in Modern Web Applications',
    'Scaling Your Application',
    'Writing Maintainable Code'
  ]

  posts = []
  post_titles.each_with_index do |title, i|
    user = all_users.sample
    post = Post.find_or_create_by!(title: title, user: user) do |p|
      p.content = Faker::Lorem.paragraphs(number: 15).join("\n\n")
      p.featured_image_url = "https://picsum.photos/1200/630?random=post-#{i + 1}"
      p.status = ['draft', 'published', 'published', 'published'].sample
      p.visibility = ['public', 'public', 'public', 'unlisted'].sample
      p.tags = ['technology', 'programming', 'tutorial', 'best-practices'].sample(3)
      p.metadata = {
        seo_title: title,
        seo_description: Faker::Lorem.paragraph(sentence_count: 2)
      }
      p.views_count = Faker::Number.between(from: 50, to: 10_000)
      p.published_at = p.status == 'published' ? Faker::Time.between(from: 60.days.ago, to: Time.current) : nil
    end
    posts << post
  end
  puts "  ✓ Created #{posts.count} posts"
end

# =============================================================================
# COMMENTS - Sample comments and replies
# =============================================================================

if Rails.env.development? && defined?(videos) && defined?(posts)
  puts "\n💬 Creating sample comments..."

  comments = []
  commentables = videos + posts

  # Top-level comments
  commentables.each do |commentable|
    comment_count = Faker::Number.between(from: 3, to: 10)
    comment_count.times do
      comment = Comment.create!(
        user: all_users.sample,
        commentable: commentable,
        content: Faker::Lorem.paragraph(sentence_count: 3),
        status: 'active'
      )
      comments << comment
    end
  end
  puts "  ✓ Created #{comments.count} top-level comments"

  # Nested replies
  reply_count = 0
  comments.sample(20).each do |comment|
    replies = Faker::Number.between(from: 1, to: 5)
    replies.times do
      Comment.create!(
        user: all_users.sample,
        commentable: comment.commentable,
        parent: comment,
        content: Faker::Lorem.paragraph(sentence_count: 2),
        status: 'active'
      )
      reply_count += 1
    end
  end
  puts "  ✓ Created #{reply_count} reply comments"
end

# =============================================================================
# REACTIONS - Sample reactions
# =============================================================================

if Rails.env.development? && defined?(videos) && defined?(posts) && defined?(comments)
  puts "\n❤️  Creating sample reactions..."

  reaction_count = 0
  reactables = videos + posts + comments

  reactables.each do |reactable|
    # Random number of unique users reacting
    all_users.sample(Faker::Number.between(from: 1, to: 10)).each do |user|
      begin
        Reaction.create!(
          user: user,
          reactable: reactable,
          type_name: Reaction::REACTION_TYPES.sample
        )
        reaction_count += 1
      rescue ActiveRecord::RecordInvalid
        # Skip if duplicate (user already reacted with this type)
      end
    end
  end
  puts "  ✓ Created #{reaction_count} reactions"
end

# =============================================================================
# REPORTS - Sample reports
# =============================================================================

if Rails.env.development? && defined?(videos) && defined?(posts) && defined?(comments)
  puts "\n🚩 Creating sample reports..."

  reportables = (videos + posts + comments).sample(10)
  reports = []

  reportables.each do |reportable|
    report = Report.create!(
      reporter: all_users.sample,
      reportable: reportable,
      reason: Report::REPORT_REASONS.sample,
      description: Faker::Lorem.paragraph(sentence_count: 3),
      status: ['pending', 'pending', 'reviewing', 'resolved', 'rejected'].sample
    )

    # Assign reviewer and resolution for reviewed reports
    if %w[reviewing resolved rejected].include?(report.status)
      report.update!(
        reviewer: moderator,
        reviewed_at: Faker::Time.between(from: 7.days.ago, to: Time.current)
      )

      if %w[resolved rejected].include?(report.status)
        report.update!(resolution: Faker::Lorem.paragraph(sentence_count: 2))
      end
    end

    reports << report
  end
  puts "  ✓ Created #{reports.count} reports"
end

# =============================================================================
# AUDIT LOGS - Sample audit logs
# =============================================================================

if Rails.env.development? && defined?(videos)
  puts "\n📋 Creating sample audit logs..."

  audit_log_count = 0
  videos.sample(5).each do |video|
    # Create action
    AuditLog.create!(
      user: video.user,
      action: 'create',
      auditable: video,
      change_data: video.attributes.except('id', 'created_at', 'updated_at'),
      metadata: { controller: 'Api::V1::VideosController', action: 'create' },
      ip_address: Faker::Internet.ip_v4_address,
      user_agent: Faker::Internet.user_agent
    )
    audit_log_count += 1

    # Update actions
    2.times do
      AuditLog.create!(
        user: video.user,
        action: 'update',
        auditable: video,
        change_data: {
          before: { title: 'Old Title', status: 'draft' },
          after: { title: video.title, status: video.status }
        },
        metadata: { controller: 'Api::V1::VideosController', action: 'update' },
        ip_address: Faker::Internet.ip_v4_address,
        user_agent: Faker::Internet.user_agent
      )
      audit_log_count += 1
    end
  end
  puts "  ✓ Created #{audit_log_count} audit logs"
end

# =============================================================================
# Summary
# =============================================================================

puts "\n✅ Database seeding completed!"
puts "\n📊 Summary:"
puts "  Users: #{User.count}"
puts "    - Admins: #{User.admins.count}"
puts "    - Moderators: #{User.moderators.count}"
puts "    - Regular Users: #{User.regular_users.count}"

if Rails.env.development?
  puts "  Videos: #{Video.count}"
  puts "    - Published: #{Video.where(status: 'published').count}"
  puts "    - Draft: #{Video.where(status: 'draft').count}"
  puts "  Posts: #{Post.count}"
  puts "    - Published: #{Post.where(status: 'published').count}"
  puts "    - Draft: #{Post.where(status: 'draft').count}"
  puts "  Comments: #{Comment.count}"
  puts "  Reactions: #{Reaction.count}"
  puts "  Reports: #{Report.count}"
  puts "  Audit Logs: #{AuditLog.count}"
end

puts "\n🔑 Sample Login Credentials:"
puts "  Admin:     admin@example.com / admin@example.com"
puts "  Moderator: moderator@example.com / moderator@example.com"
puts "  User:      user@example.com / user@example.com"
puts "\n💡 Note: Guest users don't need accounts - they can browse public content without authentication"
puts "\n🚀 Ready to use!"
