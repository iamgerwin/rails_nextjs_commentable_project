'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { postsService } from '@/services/posts.service';
import { Post, PostVisibility } from '@workspace/shared-types';
import { Search, FileText, Eye, Calendar, Clock, ChevronLeft, ChevronRight } from 'lucide-react';

export default function PostsPage() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [searchQuery, setSearchQuery] = useState('');

  const perPage = 10;

  useEffect(() => {
    fetchPosts();
  }, [page, searchQuery]);

  const fetchPosts = async () => {
    setLoading(true);
    try {
      const response = await postsService.getPosts({
        page,
        perPage,
        search: searchQuery || undefined,
        visibility: PostVisibility.PUBLIC,
      });

      if (response.success && response.data) {
        const data = Array.isArray(response.data)
          ? response.data
          : response.data.data
          ? response.data.data
          : [];
        const meta = Array.isArray(response.data) ? null : response.data.meta || response.meta;

        setPosts(data);
        setTotalPages(meta?.totalPages || 1);
      }
    } catch (error) {
      console.error('Failed to fetch posts:', error);
      setPosts([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setPage(1);
    fetchPosts();
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="border-b">
        <div className="container mx-auto px-4 py-8">
          <h1 className="text-4xl font-bold mb-4">Blog</h1>
          <p className="text-muted-foreground mb-6">
            Read our latest articles and insights
          </p>

          {/* Search */}
          <form onSubmit={handleSearch} className="flex gap-2 max-w-md">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search posts..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9"
              />
            </div>
            <Button type="submit">Search</Button>
          </form>
        </div>
      </div>

      {/* Content */}
      <div className="container mx-auto px-4 py-8">
        {loading ? (
          <div className="space-y-6">
            {[...Array(perPage)].map((_, i) => (
              <div key={i} className="space-y-3">
                <div className="h-6 w-2/3 bg-muted animate-pulse rounded" />
                <div className="h-4 bg-muted animate-pulse rounded" />
                <div className="h-4 w-3/4 bg-muted animate-pulse rounded" />
              </div>
            ))}
          </div>
        ) : posts.length === 0 ? (
          <div className="text-center py-12">
            <FileText className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
            <h3 className="text-lg font-semibold mb-2">No posts found</h3>
            <p className="text-muted-foreground">
              {searchQuery ? 'Try a different search term' : 'Check back later for new content'}
            </p>
          </div>
        ) : (
          <>
            <div className="space-y-8">
              {posts.map((post) => (
                <article
                  key={post.id}
                  className="group border-b pb-8 last:border-b-0 hover:bg-muted/50 -mx-4 px-4 py-4 rounded-lg transition-colors"
                >
                  <Link href={`/posts/${post.id}`}>
                    <div className="flex gap-6">
                      {post.featuredImageUrl && (
                        <div className="w-48 h-32 flex-shrink-0 hidden md:block">
                          <img
                            src={post.featuredImageUrl}
                            alt={post.title}
                            className="w-full h-full object-cover rounded-lg"
                          />
                        </div>
                      )}
                      <div className="flex-1 space-y-3">
                        <div>
                          <h2 className="text-2xl font-bold group-hover:underline mb-2">
                            {post.title}
                          </h2>
                          {post.excerpt && (
                            <p className="text-muted-foreground line-clamp-2">
                              {post.excerpt}
                            </p>
                          )}
                        </div>

                        <div className="flex flex-wrap items-center gap-4 text-sm text-muted-foreground">
                          {post.user && (
                            <span className="font-medium">{post.user.username}</span>
                          )}
                          <div className="flex items-center gap-1">
                            <Calendar className="h-3 w-3" />
                            <span>{new Date(post.createdAt).toLocaleDateString()}</span>
                          </div>
                          <div className="flex items-center gap-1">
                            <Eye className="h-3 w-3" />
                            <span>{post.viewsCount} views</span>
                          </div>
                          {post.readingTime && (
                            <div className="flex items-center gap-1">
                              <Clock className="h-3 w-3" />
                              <span>{post.readingTime} min read</span>
                            </div>
                          )}
                        </div>

                        {post.tags && post.tags.length > 0 && (
                          <div className="flex flex-wrap gap-2">
                            {post.tags.slice(0, 3).map((tag, i) => (
                              <Badge key={i} variant="outline">
                                #{tag}
                              </Badge>
                            ))}
                          </div>
                        )}
                      </div>
                    </div>
                  </Link>
                </article>
              ))}
            </div>

            {/* Pagination */}
            {totalPages > 1 && (
              <div className="flex items-center justify-center gap-2 mt-8">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setPage((p) => Math.max(1, p - 1))}
                  disabled={page === 1}
                >
                  <ChevronLeft className="h-4 w-4" />
                  Previous
                </Button>
                <div className="text-sm text-muted-foreground">
                  Page {page} of {totalPages}
                </div>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                  disabled={page === totalPages}
                >
                  Next
                  <ChevronRight className="h-4 w-4" />
                </Button>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}
