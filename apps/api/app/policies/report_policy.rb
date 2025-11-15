# frozen_string_literal: true

# Authorization policy for Report model
class ReportPolicy < ApplicationPolicy
  # Users can view reports list (scope will filter appropriately)
  def index?
    user.present?
  end

  # Moderators can see all reports, users can see their own
  def show?
    moderator? || owner?
  end

  # Authenticated users can create reports
  def create?
    user.present? && user.status_active?
  end

  # Only moderators can update reports (add notes)
  def update?
    moderator?
  end

  # Only moderators can review reports
  def review?
    moderator?
  end

  # Only moderators can resolve reports
  def resolve?
    moderator?
  end

  # Only moderators can reject reports
  def reject?
    moderator?
  end

  # Pundit scope for filtering reports
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.can_moderate?
        # Moderators and admins can see all reports
        scope.all
      elsif user
        # Regular users can only see their own reports
        scope.where(reporter_id: user.id)
      else
        # Guests cannot see reports
        scope.none
      end
    end
  end

  private

  def owner?
    record.respond_to?(:reporter_id) && record.reporter_id == user&.id
  end
end
