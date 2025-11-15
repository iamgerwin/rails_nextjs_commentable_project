# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Admin statistics controller for dashboard analytics and metrics
      # Only accessible by admins and moderators
      #
      # Endpoints:
      #   GET /api/v1/admin/statistics/overview (overall platform statistics)
      #   GET /api/v1/admin/statistics/users (user metrics and growth)
      #   GET /api/v1/admin/statistics/content (content metrics and engagement)
      #
      class StatisticsController < BaseController
        # GET /api/v1/admin/statistics/overview
        # Comprehensive platform overview with key metrics
        def overview
          stats = {
            # User statistics
            users: {
              total: User.count,
              active: User.where(status: 'active').count,
              suspended: User.where(status: 'suspended').count,
              deleted: User.only_deleted.count,
              verified: User.where(email_verified: true).count,
              new_today: User.where('created_at >= ?', 1.day.ago).count,
              new_this_week: User.where('created_at >= ?', 1.week.ago).count,
              new_this_month: User.where('created_at >= ?', 1.month.ago).count,
              by_role: User.group(:role).count
            },

            # Content statistics
            content: {
              videos: {
                total: Video.count,
                published: Video.where(status: 'published').count,
                draft: Video.where(status: 'draft').count,
                archived: Video.where(status: 'archived').count,
                total_views: Video.sum(:views_count),
                new_today: Video.where('created_at >= ?', 1.day.ago).count
              },
              posts: {
                total: Post.count,
                published: Post.where(status: 'published').count,
                draft: Post.where(status: 'draft').count,
                archived: Post.where(status: 'archived').count,
                total_views: Post.sum(:views_count),
                new_today: Post.where('created_at >= ?', 1.day.ago).count
              },
              comments: {
                total: Comment.count,
                active: Comment.where(status: 'active').count,
                hidden: Comment.where(status: 'hidden').count,
                flagged: Comment.where(status: 'flagged').count,
                new_today: Comment.where('created_at >= ?', 1.day.ago).count
              }
            },

            # Engagement statistics
            engagement: {
              reactions: {
                total: Reaction.count,
                by_type: Reaction.group(:type_name).count,
                new_today: Reaction.where('created_at >= ?', 1.day.ago).count
              },
              total_views: Video.sum(:views_count) + Post.sum(:views_count),
              total_comments: Comment.count,
              total_reactions: Reaction.count
            },

            # Moderation statistics
            moderation: {
              reports: {
                total: Report.count,
                pending: Report.where(status: 'pending').count,
                under_review: Report.where(status: 'under_review').count,
                resolved: Report.where(status: 'resolved').count,
                rejected: Report.where(status: 'rejected').count,
                new_today: Report.where('created_at >= ?', 1.day.ago).count,
                by_reason: Report.group(:reason).count
              }
            },

            # Audit trail statistics
            audit: {
              total_logs: AuditLog.count,
              logs_today: AuditLog.where('created_at >= ?', 1.day.ago).count,
              by_action: AuditLog.group(:action).count
            },

            # System metadata
            metadata: {
              generated_at: Time.current,
              generated_by: current_user.username
            }
          }

          render_success(stats)
        end

        # GET /api/v1/admin/statistics/users
        # Detailed user metrics and growth trends
        def users
          # Time range for trends (default: last 30 days)
          days = (params[:days] || 30).to_i
          start_date = days.days.ago

          # Daily user registrations
          daily_registrations = User
                                 .where('created_at >= ?', start_date)
                                 .group_by_day(:created_at)
                                 .count

          # User retention (users who created content after registration)
          total_users = User.count
          active_content_creators = User
                                     .joins('LEFT JOIN videos ON videos.user_id = users.id')
                                     .joins('LEFT JOIN posts ON posts.user_id = users.id')
                                     .where('videos.id IS NOT NULL OR posts.id IS NOT NULL')
                                     .distinct
                                     .count

          stats = {
            overview: {
              total: total_users,
              active: User.where(status: 'active').count,
              suspended: User.where(status: 'suspended').count,
              deleted: User.only_deleted.count,
              verified: User.where(email_verified: true).count,
              by_role: User.group(:role).count,
              by_status: User.group(:status).count
            },

            growth: {
              new_today: User.where('created_at >= ?', 1.day.ago).count,
              new_this_week: User.where('created_at >= ?', 1.week.ago).count,
              new_this_month: User.where('created_at >= ?', 1.month.ago).count,
              daily_registrations: daily_registrations
            },

            engagement: {
              content_creators: active_content_creators,
              content_creator_percentage: total_users.positive? ? (active_content_creators.to_f / total_users * 100).round(2) : 0,
              users_with_comments: User.joins(:comments).distinct.count,
              users_with_reactions: User.joins(:reactions).distinct.count
            },

            top_contributors: {
              most_videos: User.joins(:videos)
                              .select('users.*, COUNT(videos.id) as videos_count')
                              .group('users.id')
                              .order('videos_count DESC')
                              .limit(10)
                              .map { |u| { id: u.id, username: u.username, count: u.videos_count } },

              most_posts: User.joins(:posts)
                             .select('users.*, COUNT(posts.id) as posts_count')
                             .group('users.id')
                             .order('posts_count DESC')
                             .limit(10)
                             .map { |u| { id: u.id, username: u.username, count: u.posts_count } },

              most_comments: User.joins(:comments)
                                .select('users.*, COUNT(comments.id) as comments_count')
                                .group('users.id')
                                .order('comments_count DESC')
                                .limit(10)
                                .map { |u| { id: u.id, username: u.username, count: u.comments_count } }
            },

            metadata: {
              time_range_days: days,
              generated_at: Time.current
            }
          }

          render_success(stats)
        end

        # GET /api/v1/admin/statistics/content
        # Detailed content metrics and engagement trends
        def content
          # Time range for trends (default: last 30 days)
          days = (params[:days] || 30).to_i
          start_date = days.days.ago

          # Daily content creation
          daily_videos = Video
                          .where('created_at >= ?', start_date)
                          .group_by_day(:created_at)
                          .count

          daily_posts = Post
                         .where('created_at >= ?', start_date)
                         .group_by_day(:created_at)
                         .count

          daily_comments = Comment
                            .where('created_at >= ?', start_date)
                            .group_by_day(:created_at)
                            .count

          stats = {
            videos: {
              total: Video.count,
              by_status: Video.group(:status).count,
              by_visibility: Video.group(:visibility).count,
              total_views: Video.sum(:views_count),
              total_comments: Video.sum(:comments_count),
              total_reactions: Video.sum(:reactions_count),
              average_views: Video.average(:views_count).to_f.round(2),
              new_today: Video.where('created_at >= ?', 1.day.ago).count,
              published_today: Video.where('published_at >= ?', 1.day.ago).count,
              daily_creation: daily_videos,
              top_by_views: Video.order(views_count: :desc)
                                .limit(10)
                                .select(:id, :title, :views_count, :user_id)
                                .map { |v| { id: v.id, title: v.title, views: v.views_count } }
            },

            posts: {
              total: Post.count,
              by_status: Post.group(:status).count,
              by_visibility: Post.group(:visibility).count,
              total_views: Post.sum(:views_count),
              total_comments: Post.sum(:comments_count),
              total_reactions: Post.sum(:reactions_count),
              average_views: Post.average(:views_count).to_f.round(2),
              new_today: Post.where('created_at >= ?', 1.day.ago).count,
              published_today: Post.where('published_at >= ?', 1.day.ago).count,
              daily_creation: daily_posts,
              top_by_views: Post.order(views_count: :desc)
                               .limit(10)
                               .select(:id, :title, :views_count, :user_id)
                               .map { |p| { id: p.id, title: p.title, views: p.views_count } }
            },

            comments: {
              total: Comment.count,
              by_status: Comment.group(:status).count,
              total_reactions: Comment.sum(:reactions_count),
              top_level: Comment.where(parent_id: nil).count,
              replies: Comment.where.not(parent_id: nil).count,
              new_today: Comment.where('created_at >= ?', 1.day.ago).count,
              daily_creation: daily_comments,
              average_per_video: Video.average(:comments_count).to_f.round(2),
              average_per_post: Post.average(:comments_count).to_f.round(2)
            },

            reactions: {
              total: Reaction.count,
              by_type: Reaction.group(:type_name).count,
              by_reactable_type: Reaction.group(:reactable_type).count,
              new_today: Reaction.where('created_at >= ?', 1.day.ago).count
            },

            engagement_rates: {
              video_comment_rate: calculate_rate(Video.sum(:comments_count), Video.count),
              video_reaction_rate: calculate_rate(Video.sum(:reactions_count), Video.count),
              post_comment_rate: calculate_rate(Post.sum(:comments_count), Post.count),
              post_reaction_rate: calculate_rate(Post.sum(:reactions_count), Post.count)
            },

            metadata: {
              time_range_days: days,
              generated_at: Time.current
            }
          }

          render_success(stats)
        end

        private

        def calculate_rate(numerator, denominator)
          return 0 if denominator.zero?
          (numerator.to_f / denominator).round(2)
        end
      end
    end
  end
end
