# frozen_string_literal: true

module Api
  module V1
    # Reports controller with Ransack filtering and moderation actions
    # Supports reporting Videos, Posts, Comments, and Users
    #
    # Ransack Examples:
    #   GET /api/v1/reports?q[status_eq]=pending
    #   GET /api/v1/reports?q[reason_eq]=spam
    #   GET /api/v1/reports?q[reportable_type_eq]=Comment
    #   GET /api/v1/reports?q[reporter_username_cont]=john
    #   GET /api/v1/reports?q[created_at_gteq]=2024-01-01&q[s]=created_at desc
    #   GET /api/v1/reports?q[status_in][]=pending&q[status_in][]=under_review
    #
    # Moderation Actions:
    #   POST /api/v1/reports/:id/review (mark as under review)
    #   POST /api/v1/reports/:id/resolve (mark as resolved with action taken)
    #   POST /api/v1/reports/:id/reject (mark as rejected/invalid)
    #
    class ReportsController < BaseController
      before_action :authenticate_user!
      before_action :set_report, only: [:show, :update, :review, :resolve, :reject]
      before_action :authorize_report

      # GET /api/v1/reports
      # List reports with Ransack filtering
      # Regular users can only see their own reports
      # Moderators can see all reports
      def index
        @q = policy_scope(Report).ransack(params[:q])
        @reports = @q.result(distinct: true)
                     .includes(:reporter, :moderator, :reportable)
                     .page(pagination_params[:page])
                     .per(pagination_params[:per_page])

        render_success(
          ActiveModel::Serializer::CollectionSerializer.new(
            @reports,
            serializer: ReportSerializer
          ).as_json,
          meta: pagination_meta(@reports)
        )
      end

      # GET /api/v1/reports/:id
      # Show single report
      def show
        render_success(
          ReportSerializer.new(
            @report,
            include_reportable: true
          ).as_json
        )
      end

      # POST /api/v1/reports
      # Create a new report
      def create
        reportable = find_reportable

        unless reportable
          return render_error(
            'Reportable entity not found',
            code: 'REPORTABLE_NOT_FOUND',
            status: :not_found
          )
        end

        # Check if user already reported this entity
        existing_report = Report.find_by(
          reporter: current_user,
          reportable: reportable,
          status: ['pending', 'under_review']
        )

        if existing_report
          return render_error(
            'You have already reported this content',
            code: 'DUPLICATE_REPORT',
            status: :unprocessable_entity
          )
        end

        @report = Report.new(report_params)
        @report.reporter = current_user
        @report.reportable = reportable

        if @report.save
          AuditLog.log_create(@report, user: current_user)
          # TODO: Notify moderators about new report
          # NotifyModeratorsJob.perform_later(@report.id)

          render_success(
            ReportSerializer.new(@report).as_json,
            status: :created
          )
        else
          render_error(
            @report.errors.full_messages.join(', '),
            code: 'REPORT_CREATE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # PATCH/PUT /api/v1/reports/:id
      # Update report (moderator only - for adding notes)
      def update
        if @report.update(update_params)
          AuditLog.log_update(@report, user: current_user)
          render_success(ReportSerializer.new(@report).as_json)
        else
          render_error(
            @report.errors.full_messages.join(', '),
            code: 'REPORT_UPDATE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # POST /api/v1/reports/:id/review
      # Mark report as under review (moderator only)
      def review
        if @report.may_review?
          @report.moderator = current_user
          @report.review!
          AuditLog.log_update(@report, user: current_user)

          render_success(
            ReportSerializer.new(@report).as_json,
            meta: { message: 'Report marked as under review' }
          )
        else
          render_error(
            "Cannot review report from #{@report.status} status",
            code: 'INVALID_STATE_TRANSITION',
            status: :unprocessable_entity
          )
        end
      end

      # POST /api/v1/reports/:id/resolve
      # Resolve report with action taken (moderator only)
      def resolve
        if @report.may_resolve?
          @report.moderator = current_user
          @report.moderator_notes = params[:moderator_notes] if params[:moderator_notes]
          @report.resolve!
          AuditLog.log_update(@report, user: current_user)

          # Optionally take action on reported content
          if params[:action_type].present?
            take_moderation_action(params[:action_type])
          end

          render_success(
            ReportSerializer.new(@report).as_json,
            meta: { message: 'Report resolved successfully' }
          )
        else
          render_error(
            "Cannot resolve report from #{@report.status} status",
            code: 'INVALID_STATE_TRANSITION',
            status: :unprocessable_entity
          )
        end
      end

      # POST /api/v1/reports/:id/reject
      # Reject report as invalid (moderator only)
      def reject
        if @report.may_reject?
          @report.moderator = current_user
          @report.moderator_notes = params[:moderator_notes] if params[:moderator_notes]
          @report.reject!
          AuditLog.log_update(@report, user: current_user)

          render_success(
            ReportSerializer.new(@report).as_json,
            meta: { message: 'Report rejected as invalid' }
          )
        else
          render_error(
            "Cannot reject report from #{@report.status} status",
            code: 'INVALID_STATE_TRANSITION',
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

      def authorize_report
        authorize(@report || Report)
      end

      def find_reportable
        return nil unless params[:reportable_type] && params[:reportable_id]

        case params[:reportable_type]
        when 'Video'
          Video.find_by(id: params[:reportable_id])
        when 'Post'
          # Support both ID and slug for posts
          if params[:reportable_id].match?(/^\d+$/) || params[:reportable_id].match?(/^[0-9a-f]{8}-/)
            Post.find_by(id: params[:reportable_id])
          else
            Post.find_by(slug: params[:reportable_id])
          end
        when 'Comment'
          Comment.find_by(id: params[:reportable_id])
        when 'User'
          User.find_by(id: params[:reportable_id])
        end
      end

      def report_params
        params.require(:report).permit(:reason, :description)
      end

      def update_params
        params.require(:report).permit(:moderator_notes)
      end

      def take_moderation_action(action_type)
        reportable = @report.reportable

        case action_type
        when 'hide'
          reportable.hide! if reportable.respond_to?(:hide!)
        when 'delete'
          reportable.destroy if reportable.respond_to?(:destroy)
        when 'flag'
          reportable.flag! if reportable.respond_to?(:flag!)
        when 'suspend_user'
          if reportable.respond_to?(:user)
            reportable.user.suspend! if reportable.user.respond_to?(:suspend!)
          elsif reportable.is_a?(User)
            reportable.suspend! if reportable.respond_to?(:suspend!)
          end
        end

        AuditLog.create!(
          action: 'moderation_action',
          auditable: reportable,
          user: current_user,
          change_data: {
            report_id: @report.id,
            action_type: action_type,
            reason: @report.reason
          }
        )
      end
    end
  end
end
