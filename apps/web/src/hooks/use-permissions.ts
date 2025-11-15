'use client';

import { useAuth } from '@/contexts/auth-context';
import { UserRole } from '@workspace/shared-types';

export function usePermissions() {
  const { user } = useAuth();

  return {
    canManageUsers: user?.role === UserRole.ADMIN,
    canModerate: user?.role === UserRole.ADMIN || user?.role === UserRole.MODERATOR,
    canManageOwnContent: !!user,
    isAdmin: user?.role === UserRole.ADMIN,
    isModerator: user?.role === UserRole.MODERATOR,
    isUser: user?.role === UserRole.USER,
  };
}
