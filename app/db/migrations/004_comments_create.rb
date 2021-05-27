# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:comments) do
      uuid :id, primary_key: true
      foreign_key :restaurant_id, table: :restaurants

      String :content_secure
      Integer :like, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
