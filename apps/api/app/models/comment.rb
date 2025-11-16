# frozen_string_literal: true

# Comment model for polymorphic comments on videos and posts
class Comment < ApplicationRecord
  include Auditable

  # Use string IDs (UUIDs)
  before_create :generate_uuid

  # Soft delete
  acts_as_paranoid

  # Associations
  belongs_to :user
  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :parent, class_name: 'Comment', optional: true, counter_cache: :replies_count
  has_many :replies, class_name: 'Comment', foreign_key: 'parent_id', dependent: :destroy
  has_many :reactions, as: :reactable, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :audit_logs, as: :auditable, dependent: :destroy

  # Enums
  enum :status, { active: 'active', hidden: 'hidden', deleted: 'deleted', flagged: 'flagged' }, prefix: true

  # Validations
  validates :content, presence: true, length: { minimum: 1, maximum: 5000 }
  validates :status, inclusion: { in: statuses.keys }
  validate :parent_must_be_same_commentable, if: :parent_id?

  # Callbacks
  after_commit :increment_commentable_counter, on: :create
  after_commit :decrement_commentable_counter, on: :destroy

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :top_level, -> { where(parent_id: nil) }
  scope :replies_to, ->(comment_id) { where(parent_id: comment_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_commentable, ->(commentable) { where(commentable: commentable) }

  # Instance methods
  def top_level?
    parent_id.nil?
  end

  def reply?
    parent_id.present?
  end

  def hide!
    update!(status: 'hidden')
  end

  def flag!
    update!(status: 'flagged')
  end

  def activate!
    update!(status: 'active')
  end

  def editable_by?(editor)
    return false unless editor
    user_id == editor.id || editor.can_moderate?
  end

  def deletable_by?(deleter)
    return false unless deleter
    user_id == deleter.id || deleter.can_moderate?
  end

  def reaction_summary
    reactions.group(:type_name).count
  end

  def thread_depth
    depth = 0
    current = self
    while current.parent_id.present?
      depth += 1
      current = current.parent
    end
    depth
  end

  def viewable_by?(viewer = nil)
    return true if status_active?
    return false unless viewer
    user_id == viewer.id || viewer.can_moderate?
  end

  def can_reply?(replier = nil)
    return false unless replier&.status_active?
    return false unless status_active?
    true
  end

  private

  def generate_uuid
    self.id = SecureRandom.uuid if id.blank?
  end

  def parent_must_be_same_commentable
    return unless parent

    if parent.commentable_type != commentable_type || parent.commentable_id != commentable_id
      errors.add(:parent_id, 'must belong to the same commentable')
    end
  end

  def increment_commentable_counter
    return unless commentable.respond_to?(:increment!)
    commentable.increment!(:comments_count) unless parent_id
  end

  def decrement_commentable_counter
    return unless commentable.respond_to?(:decrement!)
    commentable.decrement!(:comments_count) unless parent_id
  end
end
