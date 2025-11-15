# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    association :user
    association :commentable, factory: :video
    content { Faker::Lorem.paragraph(sentence_count: 3) }
    status { 'active' }
    parent_id { nil }

    trait :active do
      status { 'active' }
    end

    trait :hidden do
      status { 'hidden' }
    end

    trait :flagged do
      status { 'flagged' }
    end

    trait :deleted do
      status { 'deleted' }
    end

    trait :on_video do
      association :commentable, factory: :video
    end

    trait :on_post do
      association :commentable, factory: :post
    end

    trait :reply do
      association :parent, factory: :comment
      after(:build) do |comment|
        # Ensure reply has same commentable as parent
        comment.commentable = comment.parent.commentable
      end
    end

    trait :with_replies do
      after(:create) do |comment|
        create_list(:comment, 3, :reply, parent: comment, commentable: comment.commentable)
      end
    end

    trait :with_reactions do
      reactions_count { Faker::Number.between(from: 1, to: 50) }
      after(:create) do |comment|
        create_list(:reaction, comment.reactions_count, reactable: comment)
      end
    end

    trait :long_content do
      content { Faker::Lorem.paragraphs(number: 5).join("\n\n") }
    end

    trait :short_content do
      content { Faker::Lorem.sentence }
    end
  end
end
