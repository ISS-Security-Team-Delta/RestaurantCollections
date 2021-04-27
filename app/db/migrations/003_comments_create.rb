# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:comments) do
      primary_key :id
      foreign_key :restaurant_id, table: :restaurants

      String :contents
      String :likes, null: false

      DataTime :created_at
      DataTime :updated_at

      unique %i[restaurant_id likes]
    end
  end
end
