# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:meals) do
      primary_key :id
      foreign_key :restaurant_id, table: :restaurants

      String :name, unique: true, null: false
      String :description, unique: true
      String :type, null: false
      Float :price, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
