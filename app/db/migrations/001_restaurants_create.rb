# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:restaurants) do
      primary_key :id

      String :name, unique: true, null: false
      String :website, unique: true
      String :address, unique: true
      String :menu
      
      DataTime :created_at
      DataTime :updated_at
    end
  end
end
