# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    association :reporter, factory: :user
    association :reportable, factory: :video
    reason { Report::REPORT_REASONS.sample }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    status { 'pending' }

    trait :pending do
      status { 'pending' }
    end

    trait :reviewing do
      status { 'reviewing' }
      association :reviewer, factory: :moderator_user
    end

    trait :resolved do
      status { 'resolved' }
      association :reviewer, factory: :moderator_user
      resolution { Faker::Lorem.paragraph(sentence_count: 2) }
      reviewed_at { Faker::Time.between(from: 7.days.ago, to: Time.current) }
    end

    trait :rejected do
      status { 'rejected' }
      association :reviewer, factory: :moderator_user
      resolution { Faker::Lorem.paragraph(sentence_count: 2) }
      reviewed_at { Faker::Time.between(from: 7.days.ago, to: Time.current) }
    end

    trait :spam do
      reason { 'spam' }
    end

    trait :harassment do
      reason { 'harassment' }
    end

    trait :inappropriate do
      reason { 'inappropriate' }
    end

    trait :misinformation do
      reason { 'misinformation' }
    end

    trait :copyright do
      reason { 'copyright' }
    end

    trait :other do
      reason { 'other' }
      description { Faker::Lorem.paragraph(sentence_count: 5) }
    end

    trait :on_video do
      association :reportable, factory: :video
    end

    trait :on_post do
      association :reportable, factory: :post
    end

    trait :on_comment do
      association :reportable, factory: :comment
    end

    trait :on_user do
      association :reportable, factory: :user
    end
  end
end
