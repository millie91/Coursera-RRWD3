class Location
  include Mongoid::Document
  store_in collection: "places"
  field :city, type: String
  field :state, type: String
  field :country, type: String
end
