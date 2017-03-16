class Place
  include ActiveModel::Model
  attr_accessor :id, :formatted_address, :location, :address_components 

  def self.mongo_client
	Mongoid::Clients.default
  end

  def self.collection
	self.mongo_client['places']
  end
end
