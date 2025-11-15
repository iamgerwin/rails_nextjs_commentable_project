# frozen_string_literal: true

# Enable UUID extension for PostgreSQL
# Note: SQLite will use string UUIDs, PostgreSQL will use native UUID type
class EnableUuidExtension < ActiveRecord::Migration[8.1]
  def change
    # Enable UUID extension for PostgreSQL
    # This is a no-op for SQLite
    enable_extension 'pgcrypto' if adapter_name == 'PostgreSQL'
  end

  private

  def adapter_name
    ActiveRecord::Base.connection.adapter_name
  end
end
