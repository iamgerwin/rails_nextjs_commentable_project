# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Admin reports controller for comprehensive report management
      # Only accessible by admins and moderators
      #
      # Ransack Examples:
      #   GET /api/v1/admin/reports?q[status_eq]=pending
      #   GET /api/v1/admin/reports?q[reason_eq]=spam
      #   GET /api/v1/admin/reports?q[reportable_type_eq]=Comment
      #   GET /api/v1/admin/reports?q[moderator_id_null]=true (unassigned reports)
      #   GET /api/v1/admin/reports?q[created_at_gteq]=2024-01-01&q[s]=created_at desc
      #
      class ReportsController < BaseController
        before_action :set_report, only: [:show, :update]

        # GET /api/v1/admin/reports
        # List all reports with comprehensive filtering and statistics
        def index
          @q = Report.ransack(params[:q])
          @reports = @q.result(distinct: true)
                       .includes(:reporter, :moderator, :reportable)
                       .page(pagination_params[:page])
                       .per(pagination_params[:per_page])

          # Calculate summary statistics by status
          stats = {
            total: Report.count,
            pending: Report.where(status: 'pending').count,
            under_review: Report.where(status: 'under_review').count,
            resolved: Report.where(status: 'resolved').count,
            rejected: Report.where(status: 'rejected').count,
            by_reason: Report.group(:reason).count,
            by_reportable_type: Report.group(:reportable_type).count,
            unassigned: Report.where(moderator_id: nil, status: ['pending', 'under_review']).count
          }

          render_success(
            ActiveModel::Serializer::CollectionSerializer.new(
              @reports,
              serializer: ReportSerializer
            ).as_json,
            meta: pagination_meta(@reports).merge(statistics: stats)
          )
        end

        # GET /api/v1/admin/reports/:id
        # Show detailed report with full context
        def show
          report_data = ReportSerializer.new(
            @report,
            include_reportable: true
          ).as_json

          # Include full audit trail for this report
          report_data[:audit_trail] = AuditLog
                                        .where(auditable: @report)
                                        .order(created_at: :desc)
                                        .select(:id, :action, :user_id, :change_data, :created_at)

          # Include related reports on the same entity
          if @report.reportable
            report_data[:related_reports] = Report
                                              .where(reportable: @report.reportable)
                                              .where.not(id: @report.id)
                                              .order(created_at: :desc)
                                              .limit(5)
                                              .select(:id, :reason, :status, :created_at)
          end

          render_success(report_data)
        end

        # PATCH/PUT /api/v1/admin/reports/:id
        # Update report with moderator notes and assignment
        def update
          if @report.update(admin_report_params)
            AuditLog.log_update(@report, user: current_user)
            render_success(
              ReportSerializer.new(@report).as_json
            )
          else
            render_error(
              @report.errors.full_messages.join(', '),
              code: 'REPORT_UPDATE_FAILED',
              status: :unprocessable_entity
            )
          end
        end

        private

        def set_report
          @report = Report.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render_error(
            'Report not found',
            code: 'REPORT_NOT_FOUND',
            status: :not_found
          )
        end

        def admin_report_params
          params.require(:report).permit(:moderator_id, :moderator_notes, :status)
        end
      end
    end
  end
end
