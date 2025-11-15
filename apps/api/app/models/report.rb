# frozen_string_literal: true

# Report model for content and user reporting
class Report < ApplicationRecord
  # Use string IDs (UUIDs)
  before_create :generate_uuid

  # Associations
  belongs_to :reporter, class_name: 'User', foreign_key: 'reporter_id'
  belongs_to :reviewer, class_name: 'User', foreign_key: 'reviewer_id', optional: true
  belongs_to :reportable, polymorphic: true
  has_many :audit_logs, as: :auditable, dependent: :destroy

  # State machine
  include AASM

  aasm column: :status do
    state :pending, initial: true
    state :reviewing
    state :resolved
    state :rejected

    event :start_review do
      transitions from: :pending, to: :reviewing
    end

    event :resolve do
      transitions from: [:pending, :reviewing], to: :resolved
      after do
        update_column(:reviewed_at, Time.current)
      end
    end

    event :reject do
      transitions from: [:pending, :reviewing], to: :rejected
      after do
        update_column(:reviewed_at, Time.current)
      end
    end
  end

  # Enums
  REPORT_REASONS = %w[spam harassment inappropriate misinformation copyright other].freeze

  # Validations
  validates :reason, presence: true, inclusion: { in: REPORT_REASONS }
  validates :description, length: { maximum: 2000 }
  validates :description, presence: true, if: -> { reason == 'other' }
  validates :resolution, length: { maximum: 2000 }

  # Callbacks
  after_commit :notify_moderators, on: :create

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :reviewing, -> { where(status: 'reviewing') }
  scope :resolved, -> { where(status: 'resolved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :by_reporter, ->(user_id) { where(reporter_id: user_id) }
  scope :by_reviewer, ->(user_id) { where(reviewer_id: user_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :unreviewed, -> { where(status: [:pending, :reviewing]) }

  # Instance methods
  def assign_reviewer!(reviewer_user)
    update!(reviewer: reviewer_user)
    start_review! if may_start_review?
  end

  def resolve_with!(resolution_text, reviewer_user)
    update!(
      resolution: resolution_text,
      reviewer: reviewer_user
    )
    resolve!
  end

  def reject_with!(resolution_text, reviewer_user)
    update!(
      resolution: resolution_text,
      reviewer: reviewer_user
    )
    reject!
  end

  def severity
    case reason
    when 'harassment', 'inappropriate' then 'high'
    when 'spam', 'misinformation' then 'medium'
    else 'low'
    end
  end

  private

  def generate_uuid
    self.id = SecureRandom.uuid if id.blank?
  end

  def notify_moderators
    # Queue background job to notify moderators
    # NotifyModeratorsJob.perform_later(id)
  end
end
