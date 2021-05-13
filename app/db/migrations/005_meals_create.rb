# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:meals) do
      uuid :id, primary_key: true
      foreign_key :restaurant_id, table: :restaurants

      String :categories
      String :name, unique: true, null: false
      String :name_eng, unique: true
      String :cost
      String :description

      DataTime :created_at
      DataTime :updated_at

      unique [:restaurant_id, :categories, :name, :name_eng]
    end
  end
end
