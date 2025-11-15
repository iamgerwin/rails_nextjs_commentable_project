# frozen_string_literal: true

# Ransack configuration for search and filtering
# Controls which attributes and associations can be searched

Ransack.configure do |config|
  # Sanitize custom predicates
  config.sanitize_custom_scope_booleans = true

  # Add custom predicates if needed
  # config.add_predicate 'custom_predicate',
  #   arel_predicate: 'matches',
  #   formatter: proc { |v| "%#{v}%" },
  #   validator: proc { |v| v.present? },
  #   type: :string

  # Hide search parameters in logs (for security)
  config.hide_sort_order_indicators = false
end

# Configure which associations and attributes are searchable per model
module Ransack
  module Adapters
    module ActiveRecord
      module Base
        # Define ransackable attributes for each model
        def self.included(base)
          base.class_eval do
            # Override ransackable_attributes to control searchable fields
            def self.ransackable_attributes(auth_object = nil)
              # By default, allow searching on most attributes except sensitive ones
              column_names - %w[password_digest email_verification_token password_reset_token]
            end

            # Override ransackable_associations to control searchable associations
            def self.ransackable_associations(auth_object = nil)
              # By default, allow searching through associations
              reflect_on_all_associations.map(&:name).map(&:to_s)
            end
          end
        end
      end
    end
  end
end
