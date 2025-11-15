# frozen_string_literal: true

FactoryBot.define do
  factory :reaction do
    association :user
    association :reactable, factory: :video
    type_name { Reaction::REACTION_TYPES.sample }

    trait :like do
      type_name { 'like' }
    end

    trait :dislike do
      type_name { 'dislike' }
    end

    trait :love do
      type_name { 'love' }
    end

    trait :clap do
      type_name { 'clap' }
    end

    trait :on_video do
      association :reactable, factory: :video
    end

    trait :on_post do
      association :reactable, factory: :post
    end

    trait :on_comment do
      association :reactable, factory: :comment
    end
  end
end
