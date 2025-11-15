# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    association :user
    title { Faker::Lorem.sentence(word_count: 8) }
    content { Faker::Lorem.paragraphs(number: 10).join("\n\n") }
    excerpt { Faker::Lorem.paragraph(sentence_count: 2) }
    slug { nil } # Will be auto-generated from title
    featured_image_url { "https://picsum.photos/1200/630?random=#{SecureRandom.hex(4)}" }
    status { 'draft' }
    visibility { 'private' }
    tags { Faker::Lorem.words(number: 5) }
    metadata do
      {
        reading_time: Faker::Number.between(from: 1, to: 15),
        seo_title: Faker::Lorem.sentence(word_count: 6),
        seo_description: Faker::Lorem.paragraph(sentence_count: 2)
      }
    end

    trait :draft do
      status { 'draft' }
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
      after(:create) do |post|
        create_list(:comment, post.comments_count, commentable: post)
      end
    end

    trait :with_reactions do
      reactions_count { Faker::Number.between(from: 1, to: 500) }
      after(:create) do |post|
        create_list(:reaction, post.reactions_count, reactable: post)
      end
    end

    trait :popular do
      published
      public
      with_views
      with_comments
      with_reactions
    end

    trait :tech_post do
      tags { ['technology', 'programming', 'tutorial', 'ruby', 'rails'] }
    end

    trait :news_post do
      tags { ['news', 'update', 'announcement'] }
    end
  end
end
