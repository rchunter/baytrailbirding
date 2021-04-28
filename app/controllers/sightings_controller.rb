require 'json'
require 'faraday'
class SightingsController < ApplicationController
  def nearby_birds
    begin
      lat = params[:lat]
      lng = params[:lng]
    rescue => e
      render status: 400, html: '400 bad request'
    else
      selected_birds = Sighting.nearby_sightings(lat,lng)
      render :json => {'bird_data':selected_birds}
    end
  end

  def update_database
    begin
      Sighting.update_from_ebird()
    rescue Faraday::ConnectionFailed => e
      render :json => {'err':'a rate limiting service has blocked this request'}'
    else
      render :json => {'msg':'sucessfully updated from ebird'}
    end
  end
end
