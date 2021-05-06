# frozen_string_literal: true

routing.post do
  new_data = JSON.parse(routing.body.read)
rescue Sequel::MassAssignmentRestriction
  Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
  routing.halt 400, { message: 'Illegal Attributes' }.to_json
rescue StandardError => e
  Api.logger.error "UKNOWN ERROR: #{e.message}"
  routing.halt 500, { message: 'Uknown server error.' }.to_json
end
