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

end