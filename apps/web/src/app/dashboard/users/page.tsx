'use client';

import { useState, useEffect } from 'react';
import { ProtectedRoute } from '@/components/auth/protected-route';
import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { DataTable, DataTableColumn } from '@/components/data-table';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Avatar } from '@/components/ui/avatar';
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from '@/components/ui/dropdown-menu';
import { usersService } from '@/services/users.service';
import { User, UserRole, UserStatus } from '@workspace/shared-types';
import { Plus, MoreVertical, Edit, Trash2, Eye, UserCheck } from 'lucide-react';

function UsersManagementContent() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [searchQuery, setSearchQuery] = useState('');

  const perPage = 10;

  useEffect(() => {
    fetchUsers();
  }, [page, searchQuery]);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const response = await usersService.getUsers({
        page,
        perPage,
        search: searchQuery || undefined,
      });

      if (response.success && response.data) {
        // Handle the response structure - data could be array or PaginatedResponse
        if (Array.isArray(response.data)) {
          // Direct array response
          setUsers(response.data);
          setTotalPages(1);
          setTotalCount(response.data.length);
        } else if (response.data.data && Array.isArray(response.data.data)) {
          // PaginatedResponse structure
          setUsers(response.data.data);
          setTotalPages(response.data.meta?.totalPages || 1);
          setTotalCount(response.data.meta?.totalCount || response.data.data.length);
        } else if (response.meta) {
          // Data is in response.data directly, meta is separate
          setUsers(Array.isArray(response.data) ? response.data : []);
          setTotalPages((response.meta.totalPages as number) || 1);
          setTotalCount((response.meta.totalCount as number) || 0);
        } else {
          // Fallback
          setUsers([]);
          setTotalPages(1);
          setTotalCount(0);
        }
      }
    } catch (error) {
      console.error('Failed to fetch users:', error);
      setUsers([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    setPage(1);
  };

  const handleDelete = async (userId: string) => {
    if (!confirm('Are you sure you want to delete this user?')) return;

    try {
      const response = await usersService.deleteUser(userId);
      if (response.success) {
        fetchUsers();
      }
    } catch (error) {
      console.error('Failed to delete user:', error);
    }
  };

  const getRoleBadge = (role: UserRole) => {
    const variants: Record<UserRole, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      [UserRole.ADMIN]: 'destructive',
      [UserRole.MODERATOR]: 'default',
      [UserRole.USER]: 'secondary',
    };

    return <Badge variant={variants[role]}>{role}</Badge>;
  };

  const getStatusBadge = (status: UserStatus) => {
    const variants: Record<UserStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      [UserStatus.ACTIVE]: 'default',
      [UserStatus.SUSPENDED]: 'destructive',
      [UserStatus.PENDING]: 'secondary',
    };

    return <Badge variant={variants[status]}>{status}</Badge>;
  };

  const columns: DataTableColumn<User>[] = [
    {
      key: 'avatar',
      header: '',
      render: (user) => (
        <Avatar className="h-8 w-8">
          {user.avatar ? (
            <img src={user.avatar} alt={user.fullName} />
          ) : (
            <div className="flex h-full w-full items-center justify-center bg-muted">
              <span className="text-xs font-medium">{user.initials}</span>
            </div>
          )}
        </Avatar>
      ),
    },
    {
      key: 'username',
      header: 'Username',
      sortable: true,
      render: (user) => (
        <div>
          <div className="font-medium">{user.username}</div>
          <div className="text-sm text-muted-foreground">{user.email}</div>
        </div>
      ),
    },
    {
      key: 'fullName',
      header: 'Name',
      sortable: true,
    },
    {
      key: 'role',
      header: 'Role',
      sortable: true,
      render: (user) => getRoleBadge(user.role),
    },
    {
      key: 'status',
      header: 'Status',
      sortable: true,
      render: (user) => getStatusBadge(user.status),
    },
    {
      key: 'createdAt',
      header: 'Joined',
      sortable: true,
      render: (user) => new Date(user.createdAt).toLocaleDateString(),
    },
  ];

  const renderActions = (user: User) => (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="sm">
          <MoreVertical className="h-4 w-4" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuItem>
          <Eye className="mr-2 h-4 w-4" />
          View Profile
        </DropdownMenuItem>
        <DropdownMenuItem>
          <Edit className="mr-2 h-4 w-4" />
          Edit User
        </DropdownMenuItem>
        <DropdownMenuItem>
          <UserCheck className="mr-2 h-4 w-4" />
          Change Role
        </DropdownMenuItem>
        <DropdownMenuItem
          className="text-destructive"
          onClick={() => handleDelete(user.id)}
        >
          <Trash2 className="mr-2 h-4 w-4" />
          Delete User
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-3xl font-bold tracking-tight">User Management</h2>
            <p className="text-muted-foreground">
              Manage all users, roles, and permissions
            </p>
          </div>
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            Add User
          </Button>
        </div>

        <DataTable
          data={users}
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
          searchPlaceholder="Search by username, name, or email..."
          emptyMessage="No users found"
          actions={renderActions}
        />
      </div>
    </DashboardLayout>
  );
}

export default function UsersManagementPage() {
  return (
    <ProtectedRoute requireAuth>
      <UsersManagementContent />
    </ProtectedRoute>
  );
}
