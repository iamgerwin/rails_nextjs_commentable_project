'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/contexts/auth-context';
import { UserRole } from '@workspace/shared-types';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requireAuth?: boolean;
  requiredRoles?: UserRole[];
  redirectTo?: string;
}

/**
 * ProtectedRoute wrapper component
 *
 * @param children - Components to render if access is granted
 * @param requireAuth - Whether authentication is required (default: true)
 * @param requiredRoles - Array of roles that have access (optional)
 * @param redirectTo - Where to redirect if access is denied (default: /auth/login)
 */
export function ProtectedRoute({
  children,
  requireAuth = true,
  requiredRoles,
  redirectTo = '/auth/login',
}: ProtectedRouteProps) {
  const router = useRouter();
  const { user, isLoading } = useAuth();

  useEffect(() => {
    // Don't redirect while still loading
    if (isLoading) return;

    // Check if authentication is required but user is not logged in
    if (requireAuth && !user) {
      router.push(redirectTo);
      return;
    }

    // Check if specific roles are required
    if (requiredRoles && user) {
      const hasRequiredRole = requiredRoles.includes(user.role as UserRole);
      if (!hasRequiredRole) {
        // User doesn't have required role, redirect to unauthorized page
        router.push('/unauthorized');
        return;
      }
    }
  }, [user, isLoading, requireAuth, requiredRoles, redirectTo, router]);

  // Show loading state while checking authentication
  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="text-center">
          <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-current border-r-transparent align-[-0.125em] motion-reduce:animate-[spin_1.5s_linear_infinite]" />
          <p className="mt-4 text-muted-foreground">Loading...</p>
        </div>
      </div>
    );
  }

  // Don't render children if authentication fails
  if (requireAuth && !user) {
    return null;
  }

  // Don't render children if role check fails
  if (requiredRoles && user) {
    const hasRequiredRole = requiredRoles.includes(user.role as UserRole);
    if (!hasRequiredRole) {
      return null;
    }
  }

  return <>{children}</>;
}

/**
 * Hook to check if user has specific role
 */
export function useRequireRole(requiredRole: UserRole) {
  const { user } = useAuth();
  return user?.role === requiredRole;
}

/**
 * Hook to check if user has any of the specified roles
 */
export function useHasAnyRole(roles: UserRole[]) {
  const { user } = useAuth();
  return user ? roles.includes(user.role as UserRole) : false;
}

/**
 * Hook to check if user is admin
 */
export function useIsAdmin() {
  return useRequireRole(UserRole.ADMIN);
}

/**
 * Hook to check if user is moderator or admin
 */
export function useIsModerator() {
  return useHasAnyRole([UserRole.ADMIN, UserRole.MODERATOR]);
}
