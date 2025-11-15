# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Admin audit logs controller for viewing immutable audit trail
      # Only accessible by admins and moderators
      # Read-only controller (no create, update, or delete)
      #
      # Ransack Examples:
      #   GET /api/v1/admin/audit_logs?q[action_eq]=create
      #   GET /api/v1/admin/audit_logs?q[auditable_type_eq]=User
      #   GET /api/v1/admin/audit_logs?q[user_id_eq]=123
      #   GET /api/v1/admin/audit_logs?q[created_at_gteq]=2024-01-01&q[s]=created_at desc
      #   GET /api/v1/admin/audit_logs?q[ip_address_eq]=192.168.1.1
      #   GET /api/v1/admin/audit_logs?q[action_in][]=update&q[action_in][]=delete
      #
      class AuditLogsController < BaseController
        before_action :set_audit_log, only: [:show]

        # GET /api/v1/admin/audit_logs
        # List all audit logs with comprehensive Ransack filtering
        def index
          @q = AuditLog.ransack(params[:q])
          @audit_logs = @q.result(distinct: true)
                          .includes(:user, :auditable)
                          .page(pagination_params[:page])
                          .per(pagination_params[:per_page])

          # Calculate summary statistics
          stats = {
            total: AuditLog.count,
            by_action: AuditLog.group(:action).count,
            by_auditable_type: AuditLog.group(:auditable_type).count,
            last_24h: AuditLog.where('created_at >= ?', 24.hours.ago).count,
            last_7d: AuditLog.where('created_at >= ?', 7.days.ago).count
          }

          render_success(
            @audit_logs.map do |log|
              {
                id: log.id,
                action: log.action,
                auditable_type: log.auditable_type,
                auditable_id: log.auditable_id,
                user: log.user ? { id: log.user.id, username: log.user.username } : nil,
                ip_address: log.ip_address,
                user_agent: log.user_agent,
                change_data: log.change_data,
                metadata: log.metadata,
                created_at: log.created_at
              }
            end,
            meta: pagination_meta(@audit_logs).merge(statistics: stats)
          )
        end

        # GET /api/v1/admin/audit_logs/:id
        # Show detailed audit log entry
        def show
          audit_log_data = {
            id: @audit_log.id,
            action: @audit_log.action,
            auditable_type: @audit_log.auditable_type,
            auditable_id: @audit_log.auditable_id,
            user: @audit_log.user ? UserSerializer.new(@audit_log.user).as_json : nil,
            ip_address: @audit_log.ip_address,
            user_agent: @audit_log.user_agent,
            change_data: @audit_log.change_data,
            metadata: @audit_log.metadata,
            created_at: @audit_log.created_at
          }

          # Include related audit logs for the same entity
          if @audit_log.auditable
            audit_log_data[:related_logs] = AuditLog
                                              .where(
                                                auditable_type: @audit_log.auditable_type,
                                                auditable_id: @audit_log.auditable_id
                                              )
                                              .where.not(id: @audit_log.id)
                                              .order(created_at: :desc)
                                              .limit(10)
                                              .select(:id, :action, :user_id, :created_at)
          end

          # Include user's recent activity
          if @audit_log.user
            audit_log_data[:user_recent_activity] = AuditLog
                                                      .where(user: @audit_log.user)
                                                      .where.not(id: @audit_log.id)
                                                      .order(created_at: :desc)
                                                      .limit(5)
                                                      .select(:id, :action, :auditable_type, :created_at)
          end

          render_success(audit_log_data)
        end

        private

        def set_audit_log
          @audit_log = AuditLog.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render_error(
            'Audit log not found',
            code: 'AUDIT_LOG_NOT_FOUND',
            status: :not_found
          )
        end
      end
    end
  end
end
