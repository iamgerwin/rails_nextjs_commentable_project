import { apiClient } from '@/lib/api-client';
import {
  Video,
  VideoCreateInput,
  VideoUpdateInput,
  VideoFilters,
  PaginatedResponse,
  ApiResponse,
} from '@workspace/shared-types';

class VideosService {
  /**
   * Get list of videos with filters
   */
  async getVideos(filters?: VideoFilters): Promise<ApiResponse<PaginatedResponse<Video>>> {
    const queryString = filters ? apiClient.buildQueryString(this.buildRansackFilters(filters)) : '';
    return apiClient.get<PaginatedResponse<Video>>(`/videos${queryString}`);
  }

  /**
   * Get single video by ID
   */
  async getVideo(id: string): Promise<ApiResponse<Video>> {
    return apiClient.get<Video>(`/videos/${id}`);
  }

  /**
   * Create new video
   */
  async createVideo(data: VideoCreateInput): Promise<ApiResponse<Video>> {
    return apiClient.post<Video>('/videos', {
      video: {
        title: data.title,
        description: data.description,
        url: data.url,
        thumbnail_url: data.thumbnailUrl,
        duration: data.duration,
        visibility: data.visibility,
        tags: data.tags,
        metadata: data.metadata,
      },
    });
  }

  /**
   * Update video
   */
  async updateVideo(id: string, data: VideoUpdateInput): Promise<ApiResponse<Video>> {
    return apiClient.patch<Video>(`/videos/${id}`, {
      video: {
        title: data.title,
        description: data.description,
        url: data.url,
        thumbnail_url: data.thumbnailUrl,
        duration: data.duration,
        status: data.status,
        visibility: data.visibility,
        tags: data.tags,
        metadata: data.metadata,
      },
    });
  }

  /**
   * Delete video
   */
  async deleteVideo(id: string): Promise<ApiResponse<{ message: string }>> {
    return apiClient.delete<{ message: string }>(`/videos/${id}`);
  }

  /**
   * Publish video
   */
  async publishVideo(id: string): Promise<ApiResponse<Video>> {
    return apiClient.post<Video>(`/videos/${id}/publish`);
  }

  /**
   * Archive video
   */
  async archiveVideo(id: string): Promise<ApiResponse<Video>> {
    return apiClient.post<Video>(`/videos/${id}/archive`);
  }

  /**
   * Build Ransack filters from VideoFilters
   */
  private buildRansackFilters(filters: VideoFilters): Record<string, unknown> {
    const ransackParams: Record<string, unknown> = {
      page: filters.page,
      per_page: filters.perPage,
    };

    const q: Record<string, unknown> = {};

    if (filters.search) {
      q.title_cont = filters.search;
    }

    if (filters.status) {
      q.status_eq = filters.status;
    }

    if (filters.visibility) {
      q.visibility_eq = filters.visibility;
    }

    if (filters.userId) {
      q.user_id_eq = filters.userId;
    }

    if (filters.tags && filters.tags.length > 0) {
      q.tags_cont_any = filters.tags;
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

export const videosService = new VideosService();
