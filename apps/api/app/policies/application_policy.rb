# frozen_string_literal: true

# Base application policy
# All Pundit policies should inherit from this class
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  # Check if user is the owner of the record
  def owner?
    record.respond_to?(:user_id) && record.user_id == user&.id
  end

  # Check if user is an admin
  def admin?
    user&.role_admin?
  end

  # Check if user is a moderator or admin
  def moderator?
    user&.can_moderate?
  end

  # Scope class for filtering records based on permissions
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
