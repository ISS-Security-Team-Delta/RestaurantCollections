# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(collaborator_id: :accounts, restaurant_id: :restaurants)
  end
end
