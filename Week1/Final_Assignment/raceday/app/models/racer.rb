class Racer
	# Add the ActiveModel::Model mixin to the Racer class
	include ActiveModel::Model
	# Add attributes to the Racer class that allow one to set/get each of the following properties: id, number, first_name, last_name, gender, group, secs
  	attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

	# Create a class method (using self prefix) called mongo_client that returns a MongoDB client configured to communicate to the default database specified in the config/mongoid.yml file. 
	def self.mongo_client
	  Mongoid::Clients.default
	end

	# Create a class method (using self prefix) called collection that returns the racers MongoDB collection holding the Racer documents.
	def self.collection
	  self.mongo_client['racers']
	end

	# Create a class method called "all" that must: 
	# Accept an optional prototype, optional sort, optional skip, and optional limit. 
	# Is to “match all” – which means you must provide it a document that matches all records. The default for sort must be by number ascending. The default for skip must be 0 and the default for limit must be nil.
	# Find all racers that match the given prototype.
	# Sort them by the given hash criteria.
	# Skip the specified number of documents.
	# Limit the number of documents returned if limit is specified.
	# Return the result.
	def self.all(prototype={}, sort={}, skip=0, limit=nil)
 	  result = collection.find(prototype).sort(sort).skip(skip)
 	    if limit then result.limit(limit)
 	    else result 
 	    end
	end

	# Create a class method in the Racer class called find. This method must:
	# Accept a single id parameter that is either a string or BSON::ObjectId Note: it must be able to handle either format.
	# Find the specific document with that _id.
	# Return the racer document represented by that id.
	def self.find id 
	  Rails.logger.debug {"finding racer id: #{id}"}
	  doc = collection.find(_id: BSON.ObjectId(id)).first 
	  doc.nil? ? nil : Racer.new(doc)
	end

	# Create an instance method in the Racer class called save. This method must:
	# Take no arguments.
	# Insert the current state of the Racer instance into the database.
	# Obtain the inserted document _id from the result and assign the to_s value of the _id to the instance attribute @id
	def save
	  result = self.class.collection.insert_one(:number => @number, :first_name => @first_name, :last_name => @last_name, :gender => @gender, :group => @group, :secs => @secs)
	  @id = result.inserted_id.to_s
	end

	# Create an instance method in the Racer class called update. This method must:
	# Accept a hash as an input parameter.
	# Updates the state of the instance variables – except for @id. That never should change.
	# Find the racer associated with the current @id instance variable in the database
	# Update the racer with the supplied values – replacing all values
	def update(params)
      @number = params[:number].to_i
      @first_name = params[:first_name]
      @last_name = params[:last_name]
      @secs = params[:secs].to_i
      @gender = params[:gender]
      @group = params[:group]

      params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)
      self.class.collection
        .find(:_id=>BSON::ObjectId.from_string(@id))
        .replace_one(params)
	end

	# Create an instance method in the Racer class called destroy. This method must:
	# Accept no arguments
	# Find the racer associated with the current @number instance variable in the database
	# Remove that instance from the database
	def destroy
	  self.class.collection
	    .find(number:@number)
	    .delete_one
	end

	# Add an initializer that can set the properties of the class using the keys from a racers document. It must:
	# Accept a hash of properties.
	# Assign instance attributes to the values from the hash.
	# For the id property, this method must test whether the hash is coming from a web page [:id] or from a
	# MongoDB query [:_id] and assign the value to whichever is non-nil.
	def initialize(params={})
	  @id = params[:_id].nil? ? params[:id] : params[:_id].to_s
	  @number = params[:number].to_i
	  @first_name = params[:first_name]
	  @last_name = params[:last_name]
	  @gender = params[:gender]
	  @group = params[:group]
	  @secs = params[:secs].to_i
	end

	# Add an instance method to the Racer class called persisted?. This method must:
	# Accept no arguments.
	# Return true when @id is not nil. Remember – we assigned @id during save when we obtained the generated primary key.
	def persisted?
	  !@id.nil? 
	end

	# Add two instance methods called created_at and updated_at to the Racer class that act as placeholders for property getters. They must:
	# Accept no arguments
	# Return nil or whatever date you would like. This is, of course, just a placeholder until we implement something that does this for real.
	def created_at
	  nil
	end

	def updated_at
	  nil
	end

	# Add a class method to the Racer class called paginate. This method must:
	# Accept a hash as input parameters.
	# Extract the :page property from that hash, convert to an integer, and default to the value of 1 if not set.
	# Extract the :per_page property from that hash, convert to an integer, and default to the value of 30 if not set
	# Find all racers sorted by number assending.
	# Limit the results to page and limit values.
	# Convert each document hash to an instance of a Racer class
	# Return a WillPaginate::Collection with the page, limit, and total values filled in – as well as the pageworth of data.
	def self.paginate(params)
	  page = (params[:page] || 1).to_i
	  limit = (params[:per_page] || 30).to_i
	  skip = (page-1)*limit

	  racers = []
	  all({}, {}, skip, limit).each do |doc|
	  	racers << Racer.new(doc)
	  end
	  total = all.count 

	  WillPaginate::Collection.create(page, limit, total) do |pager|
	  	pager.replace(racers)
	  end
	end
end