# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'sequel'

module RestaurantCollections

  # Restaurants' info
  class Restaurant < Sequel::Model
    one_to_many :meals
    one_to_many :comments
    plugin :association_dependencies, meals: :destroy, comments: :destroy
    plugin :timestamps
    
    # def initialize(new_restaurant)
    #   @id      = new_restaurant['id'] || new_id
    #   @website = new_restaurant['website']
    #   @name    = new_restaurant['name']
    #   @address = new_restaurant['address']
    #   @menu    = new_restaurant['menu'] # this will be a string for now, will be image later :D
    #  end
    # attr_reader :id, :website, :name, :address, :menu

    def to_json(options = {})
      JSON(
        {
        data: {
            type: 'restaurant',
            attributes: {
              website: website,
              name: name,
              address: address,
              menu: menu
            }
          }
          }, options
      )
    end

    # def self.setup
    #   Dir.mkdir(RestaurantCollections::STORE_DIR) unless Dir.exist? RestaurantCollections::STORE_DIR
    # end

    # def save
    #   File.write("#{RestaurantCollections::STORE_DIR}/#{id}.txt", to_json)
    # end

    # def self.find(find_id)
    #   restaurant_data = File.read("#{RestaurantCollections::STORE_DIR}/#{find_id}.txt")
    #   Restaurant.new JSON.parse(restaurant_data)
    # end

    # def self.all
    #   Dir.glob("#{RestaurantCollections::STORE_DIR}/*.txt").map do |file|
    #     file.match(%r{#{Regexp.quote(RestaurantCollections::STORE_DIR)}\/(.*)\.txt})[1]
    #   end
    # end

    # private

    # def new_id
    #   timestamp = Time.now.to_f.to_s
    #   Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    # end
  end
end
