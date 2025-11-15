# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Admin users controller for user management
      # Only accessible by admins and moderators
      #
      # Ransack Examples:
      #   GET /api/v1/admin/users?q[username_cont]=john
      #   GET /api/v1/admin/users?q[role_eq]=user&q[status_eq]=suspended
      #   GET /api/v1/admin/users?q[email_verified_eq]=false
      #   GET /api/v1/admin/users?q[created_at_gteq]=2024-01-01&q[s]=created_at desc
      #   GET /api/v1/admin/users?q[deleted_at_not_null]=true (soft deleted users)
      #
      # Admin Actions:
      #   POST /api/v1/admin/users/:id/suspend (suspend user account)
      #   POST /api/v1/admin/users/:id/activate (activate suspended user)
      #
      class UsersController < BaseController
        before_action :set_user, only: [:show, :update, :destroy, :suspend, :activate]
        before_action :authorize_admin_action, only: [:update, :destroy, :suspend, :activate]

        # GET /api/v1/admin/users
        # List all users including soft deleted (with comprehensive Ransack filtering)
        def index
          @q = User.with_deleted.ransack(params[:q])
          @users = @q.result(distinct: true)
                     .page(pagination_params[:page])
                     .per(pagination_params[:per_page])

          # Calculate summary statistics
          stats = {
            total: User.count,
            active: User.where(status: 'active').count,
            suspended: User.where(status: 'suspended').count,
            deleted: User.only_deleted.count,
            admins: User.where(role: 'admin').count,
            moderators: User.where(role: 'moderator').count
          }

          render_success(
            ActiveModel::Serializer::CollectionSerializer.new(
              @users,
              serializer: UserSerializer,
              scope: current_user
            ).as_json,
            meta: pagination_meta(@users).merge(statistics: stats)
          )
        end

        # GET /api/v1/admin/users/:id
        # Show detailed user information with audit trail
        def show
          user_data = UserSerializer.new(@user, scope: current_user).as_json

          # Include detailed statistics
          user_data[:statistics] = {
            videos_count: @user.videos.count,
            posts_count: @user.posts.count,
            comments_count: @user.comments.count,
            reactions_count: @user.reactions.count,
            reports_made: @user.reports.count,
            reports_received: Report.where(
              reportable_type: 'User',
              reportable_id: @user.id
            ).count,
            total_views: @user.videos.sum(:views_count) + @user.posts.sum(:views_count)
          }

          # Include recent audit logs (last 10)
          user_data[:recent_activity] = AuditLog
                                          .where(user: @user)
                                          .order(created_at: :desc)
                                          .limit(10)
                                          .select(:id, :action, :auditable_type, :created_at)

          render_success(user_data)
        end

        # PATCH/PUT /api/v1/admin/users/:id
        # Update user (admins can change role, status, etc.)
        def update
          if @user.update(admin_user_params)
            AuditLog.log_update(@user, user: current_user)
            render_success(
              UserSerializer.new(@user, scope: current_user).as_json
            )
          else
            render_error(
              @user.errors.full_messages.join(', '),
              code: 'USER_UPDATE_FAILED',
              status: :unprocessable_entity
            )
          end
        end

        # DELETE /api/v1/admin/users/:id
        # Soft delete user (admins only)
        def destroy
          if @user.destroy
            AuditLog.log_delete(@user, user: current_user)
            render_success({ message: 'User deleted successfully' })
          else
            render_error(
              'Failed to delete user',
              code: 'USER_DELETE_FAILED',
              status: :unprocessable_entity
            )
          end
        end

        # POST /api/v1/admin/users/:id/suspend
        # Suspend user account
        def suspend
          if @user.status_active?
            @user.update!(status: 'suspended')
            AuditLog.create!(
              action: 'suspend_user',
              auditable: @user,
              user: current_user,
              change_data: {
                reason: params[:reason],
                previous_status: 'active'
              }
            )

            render_success(
              UserSerializer.new(@user, scope: current_user).as_json,
              meta: { message: 'User suspended successfully' }
            )
          else
            render_error(
              "Cannot suspend user with #{@user.status} status",
              code: 'INVALID_STATUS',
              status: :unprocessable_entity
            )
          end
        end

        # POST /api/v1/admin/users/:id/activate
        # Activate suspended user account
        def activate
          if @user.status_suspended?
            @user.update!(status: 'active')
            AuditLog.create!(
              action: 'activate_user',
              auditable: @user,
              user: current_user,
              change_data: {
                previous_status: 'suspended'
              }
            )

            render_success(
              UserSerializer.new(@user, scope: current_user).as_json,
              meta: { message: 'User activated successfully' }
            )
          else
            render_error(
              "Cannot activate user with #{@user.status} status",
              code: 'INVALID_STATUS',
              status: :unprocessable_entity
            )
          end
        end

        private

        def set_user
          @user = User.with_deleted.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render_error(
            'User not found',
            code: 'USER_NOT_FOUND',
            status: :not_found
          )
        end

        def authorize_admin_action
          # Only admins can modify other admin accounts
          if @user.role_admin? && !current_user.role_admin?
            render_forbidden('Only admins can modify admin accounts')
          end

          # Prevent users from modifying their own account through admin endpoints
          if @user.id == current_user.id
            render_error(
              'Cannot modify your own account through admin endpoints',
              code: 'SELF_MODIFICATION_FORBIDDEN',
              status: :forbidden
            )
          end
        end

        def admin_user_params
          # Admins can change role, status, and other fields
          if current_user.role_admin?
            params.require(:user).permit(
              :username, :email, :first_name, :last_name, :bio, :avatar,
              :role, :status, :email_verified
            )
          else
            # Moderators can only change status and bio
            params.require(:user).permit(:status, :bio)
          end
        end
      end
    end
  end
end
