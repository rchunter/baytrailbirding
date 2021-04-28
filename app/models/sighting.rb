require 'faraday' #request library https://github.com/lostisland/faraday
require 'json' #for json fromatting and interp of request and response
require "#{Rails.root}/lib/wikipedia_api"
include Geokit

class Sighting < ApplicationRecord

  belongs_to :bird, primary_key: "ebirdSpeciesCode", foreign_key: "speciesCode"

  validates_associated :bird

  validates :speciesCode, uniqueness: { scope: [:obsDt, :lat, :lng, :howMany] }

  # allows mapping requests
  acts_as_mappable

  @@sf_bay_ebird_region_codes =
    [
      'US-CA-097', # sonoma
      'US-CA-055', # napa
      'US-CA-095', # solano
      'US-CA-041', # marin
      'US-CA-013', # contra costa
      'US-CA-075', # san francisco
      'US-CA-001', # alameda
      'US-CA-081', # san mateo
      'US-CA-085', # santa clara
      'US-CA-087'  # santa cruz
    ]

  @@region_birds_url = "https://api.ebird.org/v2/data/obs/%s/recent"
  # ebirds API Endpoint to request a list of all birds from geographic region
  # region code goes in %s
  # https://documenter.getpostman.com/view/664302/S1ENwy59?version=latest#3d2a17c1-2129-475c-b4c8-7d362d6000cd

  @@notable_region_birds_url = @@region_birds_url + "/notable"
  # ebirds API Endpoint to request a list of NOTABLE birds from geographic region
  # https://documenter.getpostman.com/view/664302/S1ENwy59?version=latest#397b9b8c-4ab9-4136-baae-3ffa4e5b26e4
  # all birds request doesn't tell us which are notable, so we have to reqeust both and compare

  @@ebird_api_token = "a9qvaguuedjc"
  # this should probably be loaded in
  # security is not an issue, because it's a free key that takes 5 minutes to get
  # but would make easier to config
  # passed in header uder X-eBirdApiToken

  @@default_sightings_days_back = 3
  # this needs to be an int between 1-30
  # maximum number of days back to request sightings
  # if not recent recent records are found


  # fetch data from ebird and store in database

  def self.update_from_ebird
    days_back = @@default_sightings_days_back

    # we request data from the days after our most recnt sighting
    most_recently_added_sighting = Sighting.order("created_at").last

    if most_recently_added_sighting
      if most_recently_added_sighting.created_at > 1.hour.ago

        self.add_bird_photos()
        return 429  # too many requests, maybe replace this with a custom error later

      elsif most_recently_added_sighting.created_at > @@default_sightings_days_back.days.ago
        # I don't know if this is being rounded correctly,
        # so I added 1 to the end as a saftey buffer, pls fix
        # validations will catch the extra records anyways
        days_back = (Time.now - most_recently_added_sighting.created_at).to_i + 1
      end
    end

    @@sf_bay_ebird_region_codes.each{ |region_code|

      url = @@region_birds_url % region_code

      resp = Faraday.get(url) do |req|
        req.params =  {'back':  days_back}
        #api token needs to be passed in the header
        req.headers = {"X-eBirdApiToken" => @@ebird_api_token}
      end

      body = resp.body

      sighting_hash_array = JSON.parse(body)

      # there should be a better way to do this
      # probably catching validates_associated :bird
      # on create! and using that, but I could not get that to work
      # as I am bad at rails - Rowen

      sighting_hash_array.each { |bird_sighting|

        sighted_bird = Bird.find_or_create_by(ebirdSpeciesCode: bird_sighting["speciesCode"]) do |bird|
          bird.comName = bird_sighting["comName"]
          bird.sciName = bird_sighting["sciName"]
        end

        # extract just needed keys
        bird_sighting.slice!(
          "speciesCode",
          "locName",
          "obsDt",
          "howMany",
          "lat",
          "lng"
        )
        puts bird_sighting

        self.create(bird_sighting) do |sighting|
          sighting.notable = false
        end
      }
    }
    self.add_bird_photos()
  end

  def self.add_bird_photos
    photoless_birds = Bird.where(photoURL: nil)
    photoless_birds.each do |bird|
      bird_photo = WikipediaAPI.get_images_from_names([bird["comName"]])[0]
      if bird_photo.nil?
        # retry with scientific name
        bird_photo = WikipediaAPI.get_images_from_names([bird["sciName"]])[0]
      end
      bird.photoURL = bird_photo
      bird.save
    end

  end

  def self.nearby_sightings(lat, lng)

    nearby_sightings = self.by_distance(:origin => [lat,lng]).limit(50).as_json(:include => [:bird])
    #add distance to origin
    nearby_sightings.each do |sightings|
      distance_in_miles =  Geokit::LatLng.new(lat.to_f,lng.to_f).distance_to(Geokit::LatLng.new(sightings["lat"].to_f, sightings["lng"].to_f))
      sightings["distTo"] = number_with_precision(distance_in_miles, precision: 1)
    end
    # then we flatten the hash because we dont want to redo some front end stuff out of lazyness
    nearby_sightings.each do |sightings|
      sightings["bird"].each_pair do |key, val|
        sightings[key] = val
      end
      sightings.delete("bird")
    end

    return nearby_sightings

  end

end
