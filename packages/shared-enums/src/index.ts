/**
 * Shared Enums Package
 *
 * This package contains all shared enumerations used across the monorepo.
 * It ensures consistency and prevents magic strings/numbers.
 */

/**
 * User-related enums
 */
export enum UserRole {
  ADMIN = 'admin',
  MODERATOR = 'moderator',
  USER = 'user',
}

export enum UserStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  SUSPENDED = 'suspended',
  DELETED = 'deleted',
}

/**
 * Content-related enums
 */
export enum CommentableType {
  VIDEO = 'Video',
  POST = 'Post',
}

export enum ReactionType {
  LIKE = 'like',
  DISLIKE = 'dislike',
  LOVE = 'love',
  CLAP = 'clap',
}

export enum ReactableType {
  VIDEO = 'Video',
  POST = 'Post',
  COMMENT = 'Comment',
}

export enum ReportStatus {
  PENDING = 'pending',
  UNDER_REVIEW = 'under_review',
  RESOLVED = 'resolved',
  REJECTED = 'rejected',
}

export enum ReportReason {
  SPAM = 'spam',
  HARASSMENT = 'harassment',
  INAPPROPRIATE = 'inappropriate',
  MISINFORMATION = 'misinformation',
  COPYRIGHT = 'copyright',
  OTHER = 'other',
}

export enum ReportableType {
  VIDEO = 'Video',
  POST = 'Post',
  COMMENT = 'Comment',
  USER = 'User',
}

/**
 * Video-related enums
 */
export enum VideoStatus {
  DRAFT = 'draft',
  PROCESSING = 'processing',
  PUBLISHED = 'published',
  ARCHIVED = 'archived',
  DELETED = 'deleted',
}

export enum VideoVisibility {
  PUBLIC = 'public',
  UNLISTED = 'unlisted',
  PRIVATE = 'private',
}

/**
 * Post-related enums
 */
export enum PostStatus {
  DRAFT = 'draft',
  PUBLISHED = 'published',
  ARCHIVED = 'archived',
  DELETED = 'deleted',
}

export enum PostVisibility {
  PUBLIC = 'public',
  UNLISTED = 'unlisted',
  PRIVATE = 'private',
}

/**
 * Comment-related enums
 */
export enum CommentStatus {
  ACTIVE = 'active',
  HIDDEN = 'hidden',
  DELETED = 'deleted',
  FLAGGED = 'flagged',
}

/**
 * Audit-related enums
 */
export enum AuditAction {
  CREATE = 'create',
  UPDATE = 'update',
  DELETE = 'delete',
  RESTORE = 'restore',
}

export enum AuditableType {
  USER = 'User',
  VIDEO = 'Video',
  POST = 'Post',
  COMMENT = 'Comment',
  REACTION = 'Reaction',
  REPORT = 'Report',
}

/**
 * API-related enums
 */
export enum HttpMethod {
  GET = 'GET',
  POST = 'POST',
  PUT = 'PUT',
  PATCH = 'PATCH',
  DELETE = 'DELETE',
}

export enum HttpStatus {
  OK = 200,
  CREATED = 201,
  ACCEPTED = 202,
  NO_CONTENT = 204,
  BAD_REQUEST = 400,
  UNAUTHORIZED = 401,
  FORBIDDEN = 403,
  NOT_FOUND = 404,
  UNPROCESSABLE_ENTITY = 422,
  TOO_MANY_REQUESTS = 429,
  INTERNAL_SERVER_ERROR = 500,
  SERVICE_UNAVAILABLE = 503,
}

/**
 * Pagination-related enums
 */
export enum SortOrder {
  ASC = 'asc',
  DESC = 'desc',
}

export enum DefaultPageSize {
  SMALL = 10,
  MEDIUM = 25,
  LARGE = 50,
  XLARGE = 100,
}
