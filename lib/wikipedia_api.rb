require 'faraday' #request library https://github.com/lostisland/faraday
require 'json' #for json fromatting and interp of request and response

module WikipediaAPI

  @@wikipedia_url = "https://en.wikipedia.org/w/api.php"

  # takes array of names return array of image urls or nils for failed request
  def get_images_from_names(names)

    wikimedia_params = {
      :action => "query",
      :prop => "pageimages",
      :format => "json",
      :piprop => "original",
      :titles => names.join("|"),
      :redirects => 1
    }

    resp = Faraday.get(@@wikipedia_url) do |req|
      req.params = wikimedia_params
    end

    body = resp.body

    image_data = JSON.parse(body)

    begin
      image_pages = image_data["query"]["pages"]
    rescue NoMethodError
      # no pages found, request was bad
      return names.map{|name| nil}
    end

    image_srcs = []

    image_pages.keys.each { |page_id|
      # tries to extract image, adds nil if it cannot
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

  module_function :get_images_from_names

end
