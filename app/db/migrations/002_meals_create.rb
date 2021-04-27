# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:meals) do
      primary_key :id
      foreign_key :restaurant_id, table: :restaurants

      String :categories
      String :name, unique: true, null: false
      String :name_eng, unique: true
      String :ingredients

      DataTime :created_at
      DataTime :updated_at

      unique %i[restaurant_id categories name name_eng]
    end
  end
end
