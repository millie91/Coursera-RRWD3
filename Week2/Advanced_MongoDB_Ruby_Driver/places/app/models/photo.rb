class Photo
include ActiveModel::Model
attr_accessor :id, :location
attr_writer :contents

def self.mongo_client
	Mongoid::Clients.default
end

def initialize(params=nil)
    @id = params[:_id].to_s if !params.nil? && !params[:_id].nil?
    @place = params[:metadata][:place] if !params.nil? && !params[:metadata][:place].nil?
    @location = Point.new(params[:metadata][:location]) if !params.nil? && !params[:metadata].nil?
end

def persisted?
	!@id.nil?
end

# getter
def place
	if !@place.nil?
		Place.find(@place.to_s)
	end
end

# setter
def place=(p)
	if p.is_a? String
	 @place=BSON::ObjectId.from_string(p)
	else 
	 @place=p
	end
 end

 def self.find_photos_for_place(param)
 	id = param.is_a?(String) ? BSON::ObjectId.from_string(param) : param
 	# mongo_client.database.fs.find({:metadata=>{:place=>id}})
 	mongo_client.database.fs.find("metadata.place": id)

 end

 def save
	
	if @place.is_a? Place
    @place = BSON::ObjectId.from_string(@place.id)
  end
  if !persisted?
    gps = EXIFR::JPEG.new(@contents).gps
    @contents.rewind
    description={}
    description[:content_type] = "image/jpeg"
    location=Point.new(:lng=>gps.longitude, :lat=>gps.latitude)
    description[:metadata] = {
    	:place => @place,
      :location => location.to_hash
    }
    grid_file = Mongo::Grid::File.new(@contents.read, description)
    @id = self.class.mongo_client.database.fs.insert_one(grid_file).to_s
    @location = Point.new(location.to_hash)
  else
    doc = self.class.mongo_client.database.fs.find(
      '_id': BSON::ObjectId.from_string(@id)
    ).first
    doc[:metadata][:place] = @place
    doc[:metadata][:location] = @location.to_hash
    self.class.mongo_client.database.fs.find(
      '_id': BSON::ObjectId.from_string(@id)
    ).update_one(doc)
  end
end

def self.all(offset = 0, limit = nil)
	if !limit.nil?
	docs = mongo_client.database.fs.find.skip(offset).limit(limit)
	else
	docs = mongo_client.database.fs.find.skip(offset)
	end
	docs.map{|doc| Photo.new(doc)}
end

def find_nearest_place_id(dist)
	Place.near(@location,dist).limit(1).projection({:_id=>1}).first[:_id]
end

def self.find(params)
	id = BSON::ObjectId.from_string(params)
	p = mongo_client.database.fs.find(:_id => id).first
	p.nil? ? nil : photo = Photo.new(p)
end

def contents
   f = self.class.mongo_client.database.fs.find_one(:_id=>BSON::ObjectId.from_string(@id))
    if f 
      buffer = ""
      f.chunks.reduce([]) do |x,chunk| 
          buffer << chunk.data.data 
      end
      return buffer
    end 
end

def destroy
	self.class.mongo_client.database.fs.find(:_id=>BSON::ObjectId.from_string(@id)).delete_one
end

end