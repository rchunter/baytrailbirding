include ActionView::Helpers::NumberHelper #used for number_with_precision
require 'faraday' #request library https://github.com/lostisland/faraday
require 'json' #for json fromatting and interp of request and response
require 'geo-distance' #for distance calulations

class EbirdAPI
  @@nearby_birds_url = "https://api.ebird.org/v2/data/obs/geo/recent/"
  #ebirds API Endpoint to request a list of all nearby birds from geographic location
  #https://documenter.getpostman.com/view/664302/S1ENwy59?version=latest#62b5ffb3-006e-4e8a-8e50-21d90d036edc

  @@rare_nearby_birds_url = "https://api.ebird.org/v2/data/obs/geo/recent/notable"
  #ebirds API Endpoint to request a list of nearby NOTABLE birds from geographic location
  #https://documenter.getpostman.com/view/664302/S1ENwy59?version=latest#62b5ffb3-006e-4e8a-8e50-21d90d036edc

  @@api_token = "a9qvaguuedjc"
  #this should probably be loaded in
  #security is not an issue, because its a free key that takes 5 minutes to get
  #but would make easier to config

  @@sightings_radius = 25
  #maximum distance in km of sightings to return

  @@sightings_days_back = 10
  #maximum number of days back to request sightings


  def initialize(lat, lng, num_req, num_ret, rare_birds)
    #choose the right endpoint based on whether of not be want notable sightings
    @url = @@nearby_birds_url
    if rare_birds
      @url = @@rare_nearby_birds_url
    end

    #store coords for distance funcion
    @latitude = lat
    @longitude = lng

    #construct payload for ebird api request,
    #api takes in lat and long at 2 digits of precision
    @request_params = {
                      :lat => number_with_precision(@latitude, precision: 2),
                      :lng => number_with_precision(@longitude, precision: 2),
                      :maxResults => num_req, #number of results, returns most recent first
                      :back => @@sightings_radius, #number of days back to request
                      :dist => @@sightings_radius, #radius in km for range of sightings
                      }
    @bird_data = nil #this will store an array of bird data from the ebird api

  end

  def make_nearby_birds_request
    #make the request to ebird api
    resp = Faraday.get(url) do |req|
      req.params =  @request_params
      #api token needs to be passed in the header
      req.headers = {"X-eBirdApiToken" => @@api_token }
    end

    body = resp.body

    @bird_data = JSON.parse(body)

    #calulates harvsine distance from user location to buird sighting location
    #and adds it to the bird objects under the key "distTo"
    self.add_distance_to_birds

  end

  def get_bird_photos
    #TODO
  end

  def cache_bird_data
    #TODO
  end

  private #helpers

  def add_distance_to_birds
    @bird_data.each do |bird|
      distance_in_miles = geoDistance::Haversine.geo_distance(@lat.to_f, @lng.to_f, bird["lat"].to_f, bird["lng"].to_f ).to_miles
      bird["distTo"] = number_with_precision(distance_in_miles, precision: 1);
    end
  end

end
