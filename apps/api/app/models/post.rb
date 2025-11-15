# frozen_string_literal: true

# Post model for blog posts and articles
class Post < ApplicationRecord
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
    state :published
    state :archived
    state :deleted

    event :publish do
      transitions from: [:draft, :archived], to: :published
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
  validates :content, presence: true, length: { minimum: 10 }
  validates :slug, presence: true, uniqueness: { case_sensitive: false, conditions: -> { where(deleted_at: nil) } }
  validates :slug, format: { with: /\A[a-z0-9-]+\z/, message: 'only allows lowercase letters, numbers, and hyphens' }
  validates :visibility, inclusion: { in: visibilities.keys }

  # Callbacks
  before_validation :generate_slug, if: -> { slug.blank? || title_changed? }
  before_validation :set_defaults
  before_validation :generate_excerpt, if: -> { excerpt.blank? && content.present? }

  # Scopes
  scope :published, -> { where(status: 'published') }
  scope :public_posts, -> { where(visibility: 'public') }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :recent, -> { order(published_at: :desc, created_at: :desc) }
  scope :popular, -> { order(views_count: :desc) }
  scope :most_commented, -> { order(comments_count: :desc) }
  scope :tagged_with, ->(tag) { where("tags LIKE ?", "%#{tag}%") }

  # Instance methods
  def increment_views!
    increment!(:views_count)
  end

  def viewable_by?(viewer = nil)
    return true if visibility_public? && status == 'published'
    return true if viewer && user_id == viewer.id
    return true if viewer&.can_moderate?
    visibility_unlisted? && status == 'published'
  end

  def editable_by?(editor)
    return false unless editor
    user_id == editor.id || editor.can_moderate?
  end

  def reaction_summary
    reactions.group(:type_name).count
  end

  def reading_time
    words_per_minute = 200
    word_count = content.split.size
    (word_count / words_per_minute.to_f).ceil
  end

  private

  def generate_uuid
    self.id = SecureRandom.uuid if id.blank?
  end

  def generate_slug
    base_slug = title.parameterize
    self.slug = base_slug

    # Ensure uniqueness
    counter = 1
    while Post.where(slug: slug).where.not(id: id).exists?
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end

  def set_defaults
    self.tags ||= []
    self.metadata ||= {}
  end

  def generate_excerpt
    # Strip HTML and take first 160 characters
    plain_text = content.gsub(/<\/?[^>]*>/, '')
    self.excerpt = plain_text.truncate(160, separator: ' ')
  end
end
