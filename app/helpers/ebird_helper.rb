require 'faraday'
require 'json'
include ActionView::Helpers::NumberHelper

module EbirdHelper
  def getBirdData(lat,lng, num_req=100, num_ret=1, rare=false)
    ebird_params = {  :lat => number_with_precision(lat, precision: 2),
                      :lng => number_with_precision(lng, precision: 2),
                      :maxResults => num_req,
                      :back => 10,
                      :dist => 25,
                    }

    url = "https://api.ebird.org/v2/data/obs/geo/recent/"
    if rare == true
      url = "https://api.ebird.org/v2/data/obs/geo/recent/notable"
    end

    resp = Faraday.get(url) do |req|
      req.params = ebird_params
      req.headers = {"X-eBirdApiToken" => "a9qvaguuedjc"}
    end

    body = resp.body


    bird_data = select_random_birds(JSON.parse(body),num_ret)


    #bird_data = addBirdDist(lat, lng, bird_data)
    bird_data.each do |bird|
      bird["distTo"] = number_with_precision(haversine_distance([lat.to_f,lng.to_f],
                                          [ bird["lat"].to_f,bird["lng"].to_f],
                                          true), precision: 1);
    end
    return bird_data

  end
  #need to make new function to stub it dumb hate this
  def select_random_birds(birds, num_ret)

    birds.sample(num_ret)

  end
  #def addBirdDist(lat,lng,bird_data)
  #    bird_data.map {|x| haversine_distance_wrapper(x,3)}
  #    haversine_distance(lat,lng,bird_data)


  #end

    ##
  # Haversine Distance Calculation
  #
  # Accepts two coordinates in the form
  # of a tuple. I.e.
  #   geo_a  Array(Num, Num)
  #   geo_b  Array(Num, Num)
  #   miles  Boolean
  #
  # Returns the distance between these two
  # points in either miles or kilometers
  def haversine_distance(geo_a, geo_b, miles=false)
    # Get latitude and longitude
    lat1, lon1 = geo_a
    lat2, lon2 = geo_b

    # Calculate radial arcs for latitude and longitude
    dLat = (lat2 - lat1) * Math::PI / 180
    dLon = (lon2 - lon1) * Math::PI / 180


    a = Math.sin(dLat / 2) *
        Math.sin(dLat / 2) +
        Math.cos(lat1 * Math::PI / 180) *
        Math.cos(lat2 * Math::PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2)

     c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))

    d = 6371 * c * (miles ? 1 / 1.6 : 1)
  end


  def getImageSrc(birds)
    com_names = birds.map{|bird| bird["comName"]}
    sci_names = birds.map{|bird| bird["sciName"]}
    images = getImageFromNames(com_names)
    indexes_to_retry = []
    images.each_with_index do |image, index|
      if image.nil?
        indexes_to_retry.append(index)
      end
    end
    if indexes_to_retry.length > 0
      sci_names_to_retry = indexes_to_retry.map{|index| sci_names[index]};
      two_try_src = getImageFromNames(sci_names_to_retry);
      indexes_to_retry.each_with_index do |value, index|
        images[value] = two_try_src[index]
      end
    end

    return images
  end



  def getImageFromNames(names)

    wikimedia_params = {
      :action => "query",
      :prop => "pageimages",
      :format => "json",
      :piprop => "original",
      :titles => names.join("|"),
      :redirects => 1
    }


    resp = Faraday.get("https://en.wikipedia.org/w/api.php") do |req|
      req.params = wikimedia_params
    end

    body = resp.body
    image_data = JSON.parse(body)
    begin
      image_pages = image_data["query"]["pages"]
    rescue NoMethodError
      return names.map{|name| nil}
    end
    image_srcs = []
    image_pages.keys.each { |page_id|
        begin
          page = image_pages[page_id];
          image_src = page["original"]["source"]
          image_srcs.append(image_src)
        rescue NoMethodError
          image_srcs.append(nil)
        end
    }

    return image_srcs

  end
end
