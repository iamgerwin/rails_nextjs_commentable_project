/**
 * Shared Configuration Package
 *
 * This package contains shared configuration and environment variables
 * used across the monorepo applications.
 */

/**
 * Environment variable helpers
 */
export const getEnv = (key: string, defaultValue?: string): string => {
  const value = process.env[key];
  if (!value && !defaultValue) {
    throw new Error(`Environment variable ${key} is required but not set`);
  }
  return value || defaultValue || '';
};

export const getEnvNumber = (key: string, defaultValue?: number): number => {
  const value = process.env[key];
  if (!value && defaultValue === undefined) {
    throw new Error(`Environment variable ${key} is required but not set`);
  }
  return value ? parseInt(value, 10) : (defaultValue as number);
};

export const getEnvBoolean = (key: string, defaultValue?: boolean): boolean => {
  const value = process.env[key];
  if (!value && defaultValue === undefined) {
    throw new Error(`Environment variable ${key} is required but not set`);
  }
  return value ? value.toLowerCase() === 'true' : (defaultValue as boolean);
};

/**
 * API Configuration
 */
export interface ApiConfig {
  url: string;
  version: string;
  timeout: number;
  retries: number;
}

export const getApiConfig = (): ApiConfig => ({
  url: getEnv('NEXT_PUBLIC_API_URL', 'http://localhost:3000'),
  version: getEnv('NEXT_PUBLIC_API_VERSION', 'v1'),
  timeout: getEnvNumber('API_TIMEOUT', 30000),
  retries: getEnvNumber('API_RETRIES', 3),
});

/**
 * Authentication Configuration
 */
export interface AuthConfig {
  jwtSecret: string;
  accessTokenExpiry: number;
  refreshTokenExpiry: number;
  bcryptRounds: number;
}

export const getAuthConfig = (): AuthConfig => ({
  jwtSecret: getEnv('JWT_SECRET_KEY'),
  accessTokenExpiry: getEnvNumber('JWT_ACCESS_TOKEN_EXPIRY', 3600), // 1 hour
  refreshTokenExpiry: getEnvNumber('JWT_REFRESH_TOKEN_EXPIRY', 604800), // 7 days
  bcryptRounds: getEnvNumber('BCRYPT_ROUNDS', 12),
});

/**
 * Database Configuration
 */
export interface DatabaseConfig {
  url: string;
  poolSize: number;
  timeout: number;
}

export const getDatabaseConfig = (): DatabaseConfig => ({
  url: getEnv('DATABASE_URL'),
  poolSize: getEnvNumber('DATABASE_POOL_SIZE', 5),
  timeout: getEnvNumber('DATABASE_TIMEOUT', 5000),
});

/**
 * Redis Configuration
 */
export interface RedisConfig {
  url: string;
  maxRetries: number;
  retryDelay: number;
}

export const getRedisConfig = (): RedisConfig => ({
  url: getEnv('REDIS_URL', 'redis://localhost:6379/0'),
  maxRetries: getEnvNumber('REDIS_MAX_RETRIES', 3),
  retryDelay: getEnvNumber('REDIS_RETRY_DELAY', 1000),
});

/**
 * Cache Configuration
 */
export interface CacheConfig {
  defaultTtl: number;
  maxSize: number;
  enabled: boolean;
}

export const getCacheConfig = (): CacheConfig => ({
  defaultTtl: getEnvNumber('CACHE_DEFAULT_TTL', 3600), // 1 hour
  maxSize: getEnvNumber('CACHE_MAX_SIZE', 100),
  enabled: getEnvBoolean('CACHE_ENABLED', true),
});

/**
 * Rate Limiting Configuration
 */
export interface RateLimitConfig {
  windowMs: number;
  maxRequests: number;
  enabled: boolean;
}

export const getRateLimitConfig = (): RateLimitConfig => ({
  windowMs: getEnvNumber('RATE_LIMIT_WINDOW_MS', 60000), // 1 minute
  maxRequests: getEnvNumber('RATE_LIMIT_MAX_REQUESTS', 100),
  enabled: getEnvBoolean('RATE_LIMIT_ENABLED', true),
});

/**
 * Upload Configuration
 */
export interface UploadConfig {
  maxFileSize: number;
  allowedMimeTypes: string[];
  uploadPath: string;
}

export const getUploadConfig = (): UploadConfig => ({
  maxFileSize: getEnvNumber('UPLOAD_MAX_FILE_SIZE', 10485760), // 10MB
  allowedMimeTypes: [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'video/mp4',
    'video/webm',
  ],
  uploadPath: getEnv('UPLOAD_PATH', '/uploads'),
});

/**
 * Pagination Configuration
 */
export interface PaginationConfig {
  defaultPage: number;
  defaultPerPage: number;
  maxPerPage: number;
}

export const getPaginationConfig = (): PaginationConfig => ({
  defaultPage: 1,
  defaultPerPage: getEnvNumber('PAGINATION_DEFAULT_PER_PAGE', 25),
  maxPerPage: getEnvNumber('PAGINATION_MAX_PER_PAGE', 100),
});

/**
 * Feature Flags
 */
export interface FeatureFlags {
  enableComments: boolean;
  enableReactions: boolean;
  enableReports: boolean;
  enableNotifications: boolean;
  enableAnalytics: boolean;
}

export const getFeatureFlags = (): FeatureFlags => ({
  enableComments: getEnvBoolean('FEATURE_COMMENTS', true),
  enableReactions: getEnvBoolean('FEATURE_REACTIONS', true),
  enableReports: getEnvBoolean('FEATURE_REPORTS', true),
  enableNotifications: getEnvBoolean('FEATURE_NOTIFICATIONS', false),
  enableAnalytics: getEnvBoolean('FEATURE_ANALYTICS', false),
});

/**
 * Application Configuration
 */
export interface AppConfig {
  name: string;
  env: string;
  debug: boolean;
  logLevel: string;
}

export const getAppConfig = (): AppConfig => ({
  name: getEnv('APP_NAME', 'Rails Next.js Commentable Project'),
  env: getEnv('NODE_ENV', 'development'),
  debug: getEnvBoolean('DEBUG', false),
  logLevel: getEnv('LOG_LEVEL', 'info'),
});

/**
 * CORS Configuration
 */
export interface CorsConfig {
  origin: string[];
  credentials: boolean;
  methods: string[];
}

export const getCorsConfig = (): CorsConfig => ({
  origin: getEnv('CORS_ORIGIN', '*').split(','),
  credentials: getEnvBoolean('CORS_CREDENTIALS', true),
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
});

/**
 * Combined Configuration
 */
export interface Config {
  app: AppConfig;
  api: ApiConfig;
  auth: AuthConfig;
  database: DatabaseConfig;
  redis: RedisConfig;
  cache: CacheConfig;
  rateLimit: RateLimitConfig;
  upload: UploadConfig;
  pagination: PaginationConfig;
  featureFlags: FeatureFlags;
  cors: CorsConfig;
}

export const getConfig = (): Config => ({
  app: getAppConfig(),
  api: getApiConfig(),
  auth: getAuthConfig(),
  database: getDatabaseConfig(),
  redis: getRedisConfig(),
  cache: getCacheConfig(),
  rateLimit: getRateLimitConfig(),
  upload: getUploadConfig(),
  pagination: getPaginationConfig(),
  featureFlags: getFeatureFlags(),
  cors: getCorsConfig(),
});

/**
 * Validation helper
 */
export const validateConfig = (): void => {
  try {
    getConfig();
    console.log('✓ Configuration validation successful');
  } catch (error) {
    console.error('✗ Configuration validation failed:', error);
    process.exit(1);
  }
};
