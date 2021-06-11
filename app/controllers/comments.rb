# frozen_string_literal: true

require_relative './app'

module RestaurantCollections
  # Web controller for RestaurantCollections API
  class Api < Roda
    route('comments') do |routing|
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      @com_route = "#{@api_root}/comments"

      # GET api/v1/comments/[com_id]
      routing.on String do |com_id|
        @req_comment = Comment.first(id: com_id)

        routing.get do
          comment = GetCommentQuery.call(
            requestor: @auth_account, comment: @req_comment
          )

          { data: comment }.to_json
        rescue GetCommentQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetCommentQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET COMMENT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end