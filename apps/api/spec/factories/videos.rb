# frozen_string_literal: true

FactoryBot.define do
  factory :video do
    association :user
    title { Faker::Lorem.sentence(word_count: 5) }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    url { "https://example.com/videos/#{SecureRandom.uuid}.mp4" }
    thumbnail_url { "https://example.com/thumbnails/#{SecureRandom.uuid}.jpg" }
    duration { Faker::Number.between(from: 30, to: 3600) } # 30 seconds to 1 hour
    status { 'draft' }
    visibility { 'private' }
    tags { Faker::Lorem.words(number: 5) }
    metadata do
      {
        resolution: '1080p',
        fps: 30,
        codec: 'h264',
        file_size: Faker::Number.between(from: 1_000_000, to: 100_000_000)
      }
    end

    trait :draft do
      status { 'draft' }
    end

    trait :processing do
      status { 'processing' }
    end

    trait :published do
      status { 'published' }
      published_at { Faker::Time.between(from: 30.days.ago, to: Time.current) }
    end

    trait :archived do
      status { 'archived' }
    end

    trait :public do
      visibility { 'public' }
    end

    trait :unlisted do
      visibility { 'unlisted' }
    end

    trait :private do
      visibility { 'private' }
    end

    trait :with_views do
      views_count { Faker::Number.between(from: 10, to: 10_000) }
    end

    trait :with_comments do
      comments_count { Faker::Number.between(from: 1, to: 100) }
      after(:create) do |video|
        create_list(:comment, video.comments_count, commentable: video)
      end
    end

    trait :with_reactions do
      reactions_count { Faker::Number.between(from: 1, to: 500) }
      after(:create) do |video|
        create_list(:reaction, video.reactions_count, reactable: video)
      end
    end

    trait :popular do
      published
      public
      with_views
      with_comments
      with_reactions
    end
  end
end
