# frozen_string_literal: true

# Base Action class for all action objects
# Actions encapsulate business logic for data mutations
# Following the Action pattern for clean, testable, and reusable code
#
# Usage:
#   result = MyAction.call(user: current_user, params: params)
#   if result.success?
#     render json: result.value
#   else
#     render json: { errors: result.errors }, status: :unprocessable_entity
#   end
#
class BaseAction
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_reader :errors, :value

  # Class method to call the action
  # @return [ActionResult] Result object containing success status, value, and errors
  def self.call(**args)
    action = new(**args)
    action.execute
  end

  def initialize(**args)
    @errors = []
    @value = nil
    super
  end

  # Execute the action
  # Override this method in subclasses
  # @return [ActionResult]
  def execute
    return failure(errors: ['Action not implemented']) unless respond_to?(:perform, true)

    validate!
    return failure(errors: validation_errors) if validation_errors.any?

    ActiveRecord::Base.transaction do
      result = perform
      log_audit_trail if success? && should_audit?
      result
    end
  rescue ActiveRecord::RecordInvalid => e
    failure(errors: e.record.errors.full_messages)
  rescue StandardError => e
    failure(errors: [e.message])
  end

  protected

  # Override this method in subclasses to perform the action
  # @return [ActionResult]
  def perform
    raise NotImplementedError, 'Subclasses must implement #perform'
  end

  # Validate the action
  # Override in subclasses for custom validation
  def validate!
    valid?
  end

  # Check if the action should create an audit trail
  # Override in subclasses
  # @return [Boolean]
  def should_audit?
    false
  end

  # Log audit trail
  # Override in subclasses
  def log_audit_trail
    # Implement in subclasses
  end

  # Return success result
  # @param value [Object] The successful result value
  # @return [ActionResult]
  def success(value:)
    @value = value
    ActionResult.new(success: true, value: value, errors: [])
  end

  # Return failure result
  # @param errors [Array<String>] Array of error messages
  # @return [ActionResult]
  def failure(errors:)
    @errors = Array(errors)
    ActionResult.new(success: false, value: nil, errors: @errors)
  end

  # Check if action was successful
  # @return [Boolean]
  def success?
    @errors.empty?
  end

  private

  # Get validation errors
  # @return [Array<String>]
  def validation_errors
    errors.full_messages
  end

  # ActionResult class to encapsulate action results
  class ActionResult
    attr_reader :value, :errors

    def initialize(success:, value:, errors:)
      @success = success
      @value = value
      @errors = errors
    end

    def success?
      @success
    end

    def failure?
      !@success
    end

    def error_messages
      @errors.join(', ')
    end
  end
end
