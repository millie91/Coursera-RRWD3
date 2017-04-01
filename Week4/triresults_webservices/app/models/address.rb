class Address
  attr_accessor :city, :state, :location

  #initialize Address class
  def initialize(params={})
    @city = params[:city] if params[:city]
    @state = params[:state] if params[:state]
    @location = params[:loc] if params[:loc]
  end

  #Converts point into mongo hash
  def mongoize
  	{
  		:city => @city,
  		:state => @state,
      :loc => @location.mongoize
  	}
  end

  #Return mongo object as ruby hash
  def self.mongoize object
  	case object
  		when nil then nil
  		when Hash then object
  		when Address then object.mongoize
  	end
  end

  #Returns instance of class
  def self.demongoize object
  	case object
  		when nil then nil
  		when Hash 
        loc = object[:loc] ? Point.new(object[:loc]) : nil
        Address.new(city: object[:city], state: object[:state], loc: loc)
  		when Address then Address
  	end
  end

  #Convert object to database friendly form
  def self.evolve object
  	case object
  		when nil then nil
  		when Hash then object
  		when Address then object.mongoize
  	end
  end

end