# frozen_string_literal: true

# Video authorization policy
class VideoPolicy < ApplicationPolicy
  # Anyone can view the index of public/unlisted videos
  def index?
    true
  end

  # Show policy based on visibility and ownership
  def show?
    return true if record.visibility_public?
    return true if record.visibility_unlisted?
    return true if owner? || moderator?

    false
  end

  # Only authenticated users can create videos
  def create?
    user.present?
  end

  # Only owner or moderators can update
  def update?
    owner? || moderator?
  end

  # Only owner or moderators can destroy
  def destroy?
    owner? || moderator?
  end

  # Only owner or moderators can publish
  def publish?
    owner? || moderator?
  end

  # Only owner or moderators can archive
  def archive?
    owner? || moderator?
  end

  # Scope for filtering videos based on permissions
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.can_moderate?
        # Moderators can see all videos
        scope.all
      elsif user
        # Authenticated users can see public, unlisted, and their own videos
        scope.where(visibility: ['public', 'unlisted'])
             .or(scope.where(user_id: user.id))
      else
        # Guest users can only see public videos
        scope.where(visibility: 'public')
      end
    end
  end
end
