/**
 * Shared Types Package
 *
 * This package contains all shared TypeScript types and interfaces
 * used across the frontend applications.
 */

import {
  UserRole,
  UserStatus,
  CommentableType,
  ReactionType,
  ReactableType,
  ReportStatus,
  ReportReason,
  ReportableType,
  VideoStatus,
  VideoVisibility,
  PostStatus,
  PostVisibility,
  CommentStatus,
  AuditAction,
  AuditableType,
  SortOrder,
} from '@workspace/shared-enums';

/**
 * Base interfaces
 */
export interface BaseEntity {
  id: string;
  createdAt: string;
  updatedAt: string;
}

export interface TimestampedEntity {
  createdAt: string;
  updatedAt: string;
}

export interface SoftDeletableEntity extends TimestampedEntity {
  deletedAt: string | null;
}

/**
 * User types
 */
export interface User extends BaseEntity, SoftDeletableEntity {
  email?: string; // Only shown to owner or admin
  username: string;
  firstName: string;
  lastName: string;
  fullName: string;
  initials: string;
  role: UserRole;
  status: UserStatus;
  avatar?: string;
  bio?: string;
  emailVerified?: boolean; // Only shown to owner or admin
  lastLoginAt?: string;
}

export interface UserProfile extends Omit<User, 'email' | 'emailVerified'> {
  postsCount: number;
  videosCount: number;
  commentsCount: number;
}

/**
 * Authentication types
 */
export interface AuthCredentials {
  email: string;
  password: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface AuthUser extends User {
  tokens: AuthTokens;
}

/**
 * Video types
 */
export interface Video extends BaseEntity, SoftDeletableEntity {
  title: string;
  description?: string;
  url: string;
  thumbnailUrl?: string;
  duration: number;
  status: VideoStatus;
  visibility: VideoVisibility;
  userId: string;
  user?: User;
  viewsCount: number;
  commentsCount: number;
  reactionsCount: number;
  tags: string[];
  metadata: Record<string, unknown>;
  publishedAt?: string;
}

export interface VideoCreateInput {
  title: string;
  description?: string;
  url: string;
  thumbnailUrl?: string;
  duration: number;
  visibility?: VideoVisibility;
  tags?: string[];
  metadata?: Record<string, unknown>;
}

export interface VideoUpdateInput extends Partial<VideoCreateInput> {
  status?: VideoStatus;
}

/**
 * Post types
 */
export interface Post extends BaseEntity, SoftDeletableEntity {
  title: string;
  content: string;
  excerpt?: string;
  slug: string;
  status: PostStatus;
  visibility: PostVisibility;
  userId: string;
  user?: User;
  featuredImageUrl?: string;
  viewsCount: number;
  commentsCount: number;
  reactionsCount: number;
  readingTime?: number;
  tags: string[];
  metadata: Record<string, unknown>;
  publishedAt?: string;
}

export interface PostCreateInput {
  title: string;
  content: string;
  excerpt?: string;
  visibility?: PostVisibility;
  featuredImageUrl?: string;
  tags?: string[];
  metadata?: Record<string, unknown>;
}

export interface PostUpdateInput extends Partial<PostCreateInput> {
  status?: PostStatus;
}

/**
 * Comment types
 */
export interface Comment extends BaseEntity, SoftDeletableEntity {
  content: string;
  userId: string;
  user?: User;
  commentableType: CommentableType;
  commentableId: string;
  commentable?: Video | Post;
  parentId?: string;
  parent?: Comment;
  status: CommentStatus;
  repliesCount: number;
  reactionsCount: number;
  replies?: Comment[];
}

export interface CommentCreateInput {
  content: string;
  commentableType: CommentableType;
  commentableId: string;
  parentId?: string;
}

export interface CommentUpdateInput {
  content?: string;
  status?: CommentStatus;
}

/**
 * Reaction types
 */
export interface Reaction extends BaseEntity {
  typeName: ReactionType;
  userId: string;
  user?: User;
  reactableType: ReactableType;
  reactableId: string;
  reactable?: Video | Post | Comment;
}

export interface ReactionCreateInput {
  typeName: ReactionType;
}

export interface ReactionSummary {
  [ReactionType.LIKE]: number;
  [ReactionType.DISLIKE]: number;
  [ReactionType.LOVE]: number;
  [ReactionType.CLAP]: number;
  total: number;
  userReaction?: ReactionType;
}

/**
 * Report types
 */
export interface Report extends BaseEntity {
  reason: ReportReason;
  description?: string;
  status: ReportStatus;
  reporterId: string;
  reporter?: User;
  reportableType: ReportableType;
  reportableId: string;
  reportable?: Video | Post | Comment | User;
  moderatorId?: string;
  moderator?: User;
  reviewedAt?: string;
  resolvedAt?: string;
  moderatorNotes?: string;
}

export interface ReportCreateInput {
  reason: ReportReason;
  description?: string;
  reportableType: ReportableType;
  reportableId: string;
}

export interface ReportUpdateInput {
  status?: ReportStatus;
  resolution?: string;
}

/**
 * Audit types
 */
export interface AuditLog extends BaseEntity {
  action: string;
  auditableType: AuditableType;
  auditableId: string;
  userId?: string;
  user?: User;
  changeData?: Record<string, unknown>;
  metadata?: Record<string, unknown>;
  ipAddress?: string;
  userAgent?: string;
}

/**
 * Pagination types
 */
export interface PaginationParams {
  page?: number;
  perPage?: number;
  sortBy?: string;
  sortOrder?: SortOrder;
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    currentPage: number;
    perPage: number;
    totalPages: number;
    totalCount: number;
    hasNextPage: boolean;
    hasPreviousPage: boolean;
  };
}

/**
 * API Response types
 */
export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: ApiError;
  meta?: Record<string, unknown>;
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
  validationErrors?: ValidationError[];
}

export interface ValidationError {
  field: string;
  message: string;
  code: string;
}

/**
 * Filter types
 */
export interface VideoFilters extends PaginationParams {
  userId?: string;
  status?: VideoStatus;
  visibility?: VideoVisibility;
  tags?: string[];
  search?: string;
}

export interface PostFilters extends PaginationParams {
  userId?: string;
  status?: PostStatus;
  visibility?: PostVisibility;
  tags?: string[];
  search?: string;
}

export interface CommentFilters extends PaginationParams {
  userId?: string;
  commentableType?: CommentableType;
  commentableId?: string;
  parentId?: string | null;
  status?: CommentStatus;
}

export interface ReportFilters extends PaginationParams {
  status?: ReportStatus;
  reason?: ReportReason;
  reportableType?: ReportableType;
  reporterId?: string;
  reviewerId?: string;
}

/**
 * Export all enums for convenience
 */
export {
  UserRole,
  UserStatus,
  CommentableType,
  ReactionType,
  ReactableType,
  ReportStatus,
  ReportReason,
  ReportableType,
  VideoStatus,
  VideoVisibility,
  PostStatus,
  PostVisibility,
  CommentStatus,
  AuditAction,
  AuditableType,
  SortOrder,
};
