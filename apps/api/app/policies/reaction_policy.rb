# frozen_string_literal: true

# Authorization policy for Reaction model
class ReactionPolicy < ApplicationPolicy
  # Anyone can view reactions
  def index?
    true
  end

  # Authenticated users can create reactions
  def create?
    user.present? && user.status_active?
  end

  # Only owner can delete their own reactions
  def destroy?
    owner?
  end

  # Pundit scope for filtering reactions
  class Scope < ApplicationPolicy::Scope
    def resolve
      # All reactions are publicly viewable
      scope.all
    end
  end
end
