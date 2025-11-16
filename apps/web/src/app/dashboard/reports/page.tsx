'use client';

import { useState, useEffect } from 'react';
import { ProtectedRoute } from '@/components/auth/protected-route';
import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { DataTable, DataTableColumn } from '@/components/data-table';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from '@/components/ui/dropdown-menu';
import { reportsService } from '@/services/reports.service';
import { Report, ReportStatus, ReportReason } from '@workspace/shared-types';
import { MoreVertical, Eye, CheckCircle, XCircle, AlertTriangle } from 'lucide-react';

function ReportsManagementContent() {
  const [reports, setReports] = useState<Report[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [searchQuery, setSearchQuery] = useState('');

  const perPage = 10;

  useEffect(() => {
    fetchReports();
  }, [page, searchQuery]);

  const fetchReports = async () => {
    setLoading(true);
    try {
      const response = await reportsService.getReports({
        page,
        perPage,
      });

      if (response.success && response.data) {
        if (Array.isArray(response.data)) {
          setReports(response.data);
          setTotalPages(1);
          setTotalCount(response.data.length);
        } else if (response.data.data && Array.isArray(response.data.data)) {
          setReports(response.data.data);
          setTotalPages(response.data.meta?.totalPages || 1);
          setTotalCount(response.data.meta?.totalCount || response.data.data.length);
        } else if (response.meta) {
          setReports(Array.isArray(response.data) ? response.data : []);
          setTotalPages((response.meta.totalPages as number) || 1);
          setTotalCount((response.meta.totalCount as number) || 0);
        } else {
          setReports([]);
          setTotalPages(1);
          setTotalCount(0);
        }
      }
    } catch (error) {
      console.error('Failed to fetch reports:', error);
      setReports([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    setPage(1);
  };

  const handleResolve = async (reportId: string) => {
    try {
      const response = await reportsService.resolveReport(reportId);
      if (response.success) {
        fetchReports();
      }
    } catch (error) {
      console.error('Failed to resolve report:', error);
    }
  };

  const handleReject = async (reportId: string) => {
    try {
      const response = await reportsService.rejectReport(reportId);
      if (response.success) {
        fetchReports();
      }
    } catch (error) {
      console.error('Failed to reject report:', error);
    }
  };

  const handleReview = async (reportId: string) => {
    try {
      const response = await reportsService.reviewReport(reportId);
      if (response.success) {
        fetchReports();
      }
    } catch (error) {
      console.error('Failed to review report:', error);
    }
  };

  const getStatusBadge = (status: ReportStatus) => {
    const variants: Record<ReportStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      [ReportStatus.PENDING]: 'destructive',
      [ReportStatus.UNDER_REVIEW]: 'secondary',
      [ReportStatus.RESOLVED]: 'default',
      [ReportStatus.REJECTED]: 'outline',
    };

    return <Badge variant={variants[status]}>{status.replace('_', ' ')}</Badge>;
  };

  const getReasonBadge = (reason: ReportReason) => {
    const variants: Record<ReportReason, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      [ReportReason.SPAM]: 'destructive',
      [ReportReason.HARASSMENT]: 'destructive',
      [ReportReason.HATE_SPEECH]: 'destructive',
      [ReportReason.MISINFORMATION]: 'secondary',
      [ReportReason.INAPPROPRIATE_CONTENT]: 'secondary',
      [ReportReason.COPYRIGHT_VIOLATION]: 'outline',
      [ReportReason.OTHER]: 'outline',
    };

    return <Badge variant={variants[reason]}>{reason.replace(/_/g, ' ')}</Badge>;
  };

  const columns: DataTableColumn<Report>[] = [
    {
      key: 'reason',
      header: 'Reason',
      sortable: true,
      render: (report) => getReasonBadge(report.reason),
    },
    {
      key: 'reportable',
      header: 'Target',
      render: (report) => (
        <div className="text-sm">
          <div className="font-medium">{report.reportableType}</div>
          {report.description && (
            <div className="text-xs text-muted-foreground line-clamp-1 max-w-xs">
              {report.description}
            </div>
          )}
        </div>
      ),
    },
    {
      key: 'reporter',
      header: 'Reporter',
      render: (report) => (
        <div className="text-sm">
          {report.reporter ? report.reporter.username : 'Unknown'}
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      sortable: true,
      render: (report) => getStatusBadge(report.status),
    },
    {
      key: 'moderator',
      header: 'Moderator',
      render: (report) => (
        <div className="text-sm">
          {report.moderator ? report.moderator.username : '-'}
        </div>
      ),
    },
    {
      key: 'createdAt',
      header: 'Reported',
      sortable: true,
      render: (report) => new Date(report.createdAt).toLocaleDateString(),
    },
  ];

  const renderActions = (report: Report) => (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="sm">
          <MoreVertical className="h-4 w-4" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuItem>
          <Eye className="mr-2 h-4 w-4" />
          View Details
        </DropdownMenuItem>
        {report.status === ReportStatus.PENDING && (
          <DropdownMenuItem onClick={() => handleReview(report.id)}>
            <AlertTriangle className="mr-2 h-4 w-4" />
            Mark Under Review
          </DropdownMenuItem>
        )}
        {report.status !== ReportStatus.RESOLVED && (
          <DropdownMenuItem onClick={() => handleResolve(report.id)}>
            <CheckCircle className="mr-2 h-4 w-4" />
            Resolve Report
          </DropdownMenuItem>
        )}
        {report.status !== ReportStatus.REJECTED && (
          <DropdownMenuItem onClick={() => handleReject(report.id)}>
            <XCircle className="mr-2 h-4 w-4" />
            Dismiss Report
          </DropdownMenuItem>
        )}
      </DropdownMenuContent>
    </DropdownMenu>
  );

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-3xl font-bold tracking-tight">Reports Management</h2>
            <p className="text-muted-foreground">
              Review and handle user-submitted reports
            </p>
          </div>
        </div>

        <DataTable
          data={reports}
          columns={columns}
          loading={loading}
          pagination={{
            currentPage: page,
            totalPages,
            totalCount,
            perPage,
          }}
          onPageChange={setPage}
          onSearch={handleSearch}
          searchPlaceholder="Search reports..."
          emptyMessage="No reports found"
          actions={renderActions}
        />
      </div>
    </DashboardLayout>
  );
}

export default function ReportsManagementPage() {
  return (
    <ProtectedRoute requireAuth>
      <ReportsManagementContent />
    </ProtectedRoute>
  );
}
