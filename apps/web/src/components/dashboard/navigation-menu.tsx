'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import { usePermissions } from '@/hooks/use-permissions';
import {
  Home,
  Video,
  FileText,
  MessageSquare,
  Users,
  Shield,
  AlertTriangle,
} from 'lucide-react';

interface NavItem {
  href: string;
  label: string;
  icon: React.ComponentType<{ className?: string }>;
  requiresPermission?: 'admin' | 'moderator';
}

const navigationItems: NavItem[] = [
  {
    href: '/dashboard',
    label: 'Dashboard',
    icon: Home,
  },
  {
    href: '/dashboard/my-videos',
    label: 'My Videos',
    icon: Video,
  },
  {
    href: '/dashboard/my-posts',
    label: 'My Posts',
    icon: FileText,
  },
  {
    href: '/dashboard/my-comments',
    label: 'My Comments',
    icon: MessageSquare,
  },
];

const adminNavigationItems: NavItem[] = [
  {
    href: '/dashboard/users',
    label: 'Users',
    icon: Users,
    requiresPermission: 'admin',
  },
  {
    href: '/dashboard/videos',
    label: 'All Videos',
    icon: Video,
    requiresPermission: 'moderator',
  },
  {
    href: '/dashboard/posts',
    label: 'All Posts',
    icon: FileText,
    requiresPermission: 'moderator',
  },
  {
    href: '/dashboard/comments',
    label: 'Comments Moderation',
    icon: Shield,
    requiresPermission: 'moderator',
  },
  {
    href: '/dashboard/reports',
    label: 'Reports',
    icon: AlertTriangle,
    requiresPermission: 'moderator',
  },
];

export function NavigationMenu() {
  const pathname = usePathname();
  const { canManageUsers, canModerate } = usePermissions();

  const isActiveLink = (href: string) => {
    if (href === '/dashboard') {
      return pathname === href;
    }
    return pathname?.startsWith(href);
  };

  const canAccessItem = (item: NavItem) => {
    if (!item.requiresPermission) return true;
    if (item.requiresPermission === 'admin') return canManageUsers;
    if (item.requiresPermission === 'moderator') return canModerate;
    return false;
  };

  const filteredAdminItems = adminNavigationItems.filter(canAccessItem);

  return (
    <nav className="space-y-6">
      {/* Main Navigation */}
      <div className="space-y-1">
        {navigationItems.map((item) => {
          const Icon = item.icon;
          const isActive = isActiveLink(item.href);

          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                isActive
                  ? 'bg-primary text-primary-foreground'
                  : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground'
              )}
            >
              <Icon className="h-5 w-5" />
              {item.label}
            </Link>
          );
        })}
      </div>

      {/* Admin Section */}
      {filteredAdminItems.length > 0 && (
        <div className="space-y-1">
          <div className="px-3 py-2">
            <h3 className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
              Administration
            </h3>
          </div>
          {filteredAdminItems.map((item) => {
            const Icon = item.icon;
            const isActive = isActiveLink(item.href);

            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                  isActive
                    ? 'bg-primary text-primary-foreground'
                    : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground'
                )}
              >
                <Icon className="h-5 w-5" />
                {item.label}
              </Link>
            );
          })}
        </div>
      )}
    </nav>
  );
}
