# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    username { Faker::Internet.unique.username(specifier: 3..30, separators: %w[_]) }
    password { 'password123' }
    password_confirmation { 'password123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    bio { Faker::Lorem.paragraph }
    role { 'user' }
    status { 'active' }
    email_verified { true }
    email_verified_at { Time.current }

    trait :unverified do
      email_verified { false }
      email_verified_at { nil }
      email_verification_token { SecureRandom.urlsafe_base64(32) }
    end

    trait :moderator do
      role { 'moderator' }
    end

    trait :admin do
      role { 'admin' }
    end

    trait :inactive do
      status { 'inactive' }
    end

    trait :suspended do
      status { 'suspended' }
    end

    trait :with_avatar do
      avatar { Faker::Avatar.image }
    end

    trait :with_login_history do
      last_login_at { Faker::Time.between(from: 7.days.ago, to: Time.current) }
      last_login_ip { Faker::Internet.ip_v4_address }
      sign_in_count { Faker::Number.between(from: 1, to: 100) }
    end

    # Sample users with specific credentials
    factory :admin_user, traits: [:admin] do
      email { 'admin@example.com' }
      username { 'admin' }
      password { 'admin@example.com' }
      password_confirmation { 'admin@example.com' }
      first_name { 'Admin' }
      last_name { 'User' }
    end

    factory :moderator_user, traits: [:moderator] do
      email { 'moderator@example.com' }
      username { 'moderator' }
      password { 'moderator@example.com' }
      password_confirmation { 'moderator@example.com' }
      first_name { 'Moderator' }
      last_name { 'User' }
    end

    factory :regular_user do
      email { 'user@example.com' }
      username { 'user' }
      password { 'user@example.com' }
      password_confirmation { 'user@example.com' }
      first_name { 'Regular' }
      last_name { 'User' }
    end
  end
end
