# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:comments) do
      uuid :id, primary_key: true
      foreign_key :restaurant_id, table: :restaurants

      String :content_secure
      String :likes, null: false

      DataTime :created_at
      DataTime :updated_at

      unique [:restaurant_id]
    end
  end
end