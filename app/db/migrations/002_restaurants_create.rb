# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:restaurants) do
      primary_key :id
      foreign_key :owner_id, :accounts

      String :name, unique: true, null: false
      String :website, unique: true
      String :address, unique: true
      String :menu

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
