# frozen_string_literal: true

FactoryBot.define do
  factory :audit_log do
    association :user
    association :auditable, factory: :video
    action { AuditLog::AUDIT_ACTIONS.sample }
    change_data { { title: ['Old Title', 'New Title'] } }
    metadata { { controller: 'Api::V1::VideosController', action: 'update' } }
    ip_address { Faker::Internet.ip_v4_address }
    user_agent { Faker::Internet.user_agent }

    trait :create_action do
      action { 'create' }
      change_data { build(:video).attributes }
    end

    trait :update_action do
      action { 'update' }
      change_data do
        {
          before: { title: 'Old Title', status: 'draft' },
          after: { title: 'New Title', status: 'published' }
        }
      end
    end

    trait :delete_action do
      action { 'delete' }
      change_data { build(:video).attributes }
    end

    trait :restore_action do
      action { 'restore' }
      change_data { build(:video).attributes }
    end

    trait :system_action do
      user { nil }
      metadata { { source: 'system', automated: true } }
    end

    trait :for_video do
      association :auditable, factory: :video
    end

    trait :for_post do
      association :auditable, factory: :post
    end

    trait :for_user do
      association :auditable, factory: :user
    end
  end
end
