# frozen_string_literal: true

# Reaction model for polymorphic reactions (like, dislike, love, clap)
class Reaction < ApplicationRecord
  include Auditable

  # Use string IDs (UUIDs)
  before_create :generate_uuid

  # Associations
  belongs_to :user
  belongs_to :reactable, polymorphic: true, counter_cache: :reactions_count
  has_many :audit_logs, as: :auditable, dependent: :destroy

  # Enums for reaction types
  REACTION_TYPES = %w[like dislike love clap].freeze

  # Validations
  validates :type_name, presence: true, inclusion: { in: REACTION_TYPES }
  validates :user_id, uniqueness: {
    scope: [:reactable_type, :reactable_id, :type_name],
    message: 'has already reacted with this type'
  }

  # Scopes
  scope :likes, -> { where(type_name: 'like') }
  scope :dislikes, -> { where(type_name: 'dislike') }
  scope :loves, -> { where(type_name: 'love') }
  scope :claps, -> { where(type_name: 'clap') }
  scope :for_reactable, ->(reactable) { where(reactable: reactable) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  # Class methods
  def self.reaction_type_emoji(type)
    case type
    when 'like' then '👍'
    when 'dislike' then '👎'
    when 'love' then '❤️'
    when 'clap' then '👏'
    else '⭐'
    end
  end

  # Instance methods
  def emoji
    self.class.reaction_type_emoji(type_name)
  end

  private

  def generate_uuid
    self.id = SecureRandom.uuid if id.blank?
  end
end
