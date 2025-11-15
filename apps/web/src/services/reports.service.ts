import { apiClient } from '@/lib/api-client';
import {
  Report,
  ReportFilters,
  ReportReason,
  ReportableType,
  PaginatedResponse,
  ApiResponse,
} from '@workspace/shared-types';

interface ReportCreateRequest {
  reportableType: ReportableType;
  reportableId: string;
  reason: ReportReason;
  description?: string;
}

class ReportsService {
  /**
   * Get list of reports (user's own or all if moderator)
   */
  async getReports(filters?: ReportFilters): Promise<ApiResponse<PaginatedResponse<Report>>> {
    const queryString = filters ? apiClient.buildQueryString(this.buildRansackFilters(filters)) : '';
    return apiClient.get<PaginatedResponse<Report>>(`/reports${queryString}`);
  }

  /**
   * Get single report
   */
  async getReport(id: string): Promise<ApiResponse<Report>> {
    return apiClient.get<Report>(`/reports/${id}`);
  }

  /**
   * Create report
   */
  async createReport(data: ReportCreateRequest): Promise<ApiResponse<Report>> {
    return apiClient.post<Report>('/reports', {
      reportable_type: data.reportableType,
      reportable_id: data.reportableId,
      report: {
        reason: data.reason,
        description: data.description,
      },
    });
  }

  /**
   * Update report (moderator only - add notes)
   */
  async updateReport(id: string, moderatorNotes: string): Promise<ApiResponse<Report>> {
    return apiClient.patch<Report>(`/reports/${id}`, {
      report: {
        moderator_notes: moderatorNotes,
      },
    });
  }

  /**
   * Review report (moderator only)
   */
  async reviewReport(id: string): Promise<ApiResponse<Report>> {
    return apiClient.post<Report>(`/reports/${id}/review`);
  }

  /**
   * Resolve report (moderator only)
   */
  async resolveReport(
    id: string,
    moderatorNotes?: string,
    actionType?: 'hide' | 'delete' | 'flag' | 'suspend_user'
  ): Promise<ApiResponse<Report>> {
    return apiClient.post<Report>(`/reports/${id}/resolve`, {
      moderator_notes: moderatorNotes,
      action_type: actionType,
    });
  }

  /**
   * Reject report (moderator only)
   */
  async rejectReport(id: string, moderatorNotes?: string): Promise<ApiResponse<Report>> {
    return apiClient.post<Report>(`/reports/${id}/reject`, {
      moderator_notes: moderatorNotes,
    });
  }

  /**
   * Build Ransack filters from ReportFilters
   */
  private buildRansackFilters(filters: ReportFilters): Record<string, unknown> {
    const ransackParams: Record<string, unknown> = {
      page: filters.page,
      per_page: filters.perPage,
    };

    const q: Record<string, unknown> = {};

    if (filters.status) {
      q.status_eq = filters.status;
    }

    if (filters.reason) {
      q.reason_eq = filters.reason;
    }

    if (filters.reportableType) {
      q.reportable_type_eq = filters.reportableType;
    }

    if (filters.reporterId) {
      q.reporter_id_eq = filters.reporterId;
    }

    if (filters.reviewerId) {
      q.moderator_id_eq = filters.reviewerId;
    }

    if (filters.sortBy) {
      q.s = `${filters.sortBy} ${filters.sortOrder || 'desc'}`;
    }

    if (Object.keys(q).length > 0) {
      ransackParams.q = q;
    }

    return ransackParams;
  }
}

export const reportsService = new ReportsService();
