class Place
	include ActiveModel::Model
	attr_accessor :id, :formatted_address, :location, :address_components 

	def initialize(params)
		@id = params[:_id].to_s
		@formatted_address = params[:formatted_address]
		@address_components = []
	    if !params[:address_components].nil?
	      address_components = params[:address_components]
	      address_components.each { |a| @address_components << AddressComponent.new(a) }
	    end
		@location = Point.new(params[:geometry][:geolocation])
	end

	def self.mongo_client
		Mongoid::Clients.default
	end

	def persisted? 
		!@id.nil?
	end

	def self.collection
		self.mongo_client['places']
	end

	def self.load_all(f)
		file=File.read(f)
	    hash=JSON.parse(file)
	    place=collection.insert_many(hash)
	end

	def self.find_by_short_name(s)
		collection.find({"address_components.short_name":s})
	end
end