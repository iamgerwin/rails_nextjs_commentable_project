# frozen_string_literal: true

# Video model for video content management
class Video < ApplicationRecord
  # Use string IDs (UUIDs)
  before_create :generate_uuid

  # Soft delete
  acts_as_paranoid

  # Associations
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :reactions, as: :reactable, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :audit_logs, as: :auditable, dependent: :destroy

  # State machine
  include AASM

  aasm column: :status do
    state :draft, initial: true
    state :processing
    state :published
    state :archived
    state :deleted

    event :process do
      transitions from: :draft, to: :processing
    end

    event :publish do
      transitions from: [:draft, :processing, :archived], to: :published
      after do
        update_column(:published_at, Time.current) unless published_at
      end
    end

    event :archive do
      transitions from: [:draft, :published], to: :archived
    end

    event :mark_as_deleted do
      transitions from: [:draft, :published, :archived], to: :deleted
    end
  end

  # Enums
  enum :visibility, { public: 'public', unlisted: 'unlisted', private: 'private' }, prefix: true

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 200 }
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :duration, numericality: { greater_than_or_equal_to: 0 }
  validates :visibility, inclusion: { in: visibilities.keys }

  # Callbacks
  before_validation :set_defaults
  after_commit :increment_user_videos_count, on: :create
  after_commit :decrement_user_videos_count, on: :destroy

  # Scopes
  scope :published, -> { where(status: 'published') }
  scope :public_videos, -> { where(visibility: 'public') }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { order(views_count: :desc) }
  scope :most_commented, -> { order(comments_count: :desc) }

  # Instance methods
  def increment_views!
    increment!(:views_count)
  end

  def viewable_by?(viewer = nil)
    return true if visibility_public?
    return true if viewer && user_id == viewer.id
    return true if viewer&.can_moderate?
    visibility_unlisted?
  end

  def editable_by?(editor)
    return false unless editor
    user_id == editor.id || editor.can_moderate?
  end

  def reaction_summary
    reactions.group(:type_name).count
  end

  private

  def generate_uuid
    self.id = SecureRandom.uuid if id.blank?
  end

  def set_defaults
    self.tags ||= []
    self.metadata ||= {}
  end

  def increment_user_videos_count
    # Placeholder for counter cache if we add one to users
  end

  def decrement_user_videos_count
    # Placeholder for counter cache if we add one to users
  end
end
