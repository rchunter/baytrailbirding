require 'rails_helper'
require 'vcr'

# Specs in this file have access to a helper object that includes
# the EbirdHelper. For example:
#
# describe EbirdHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe EbirdHelper, type: :helper do

  it "given coords, it returns a nearby bird" do
      VCR.use_cassette('ebird/get_bird_from_cords') do
        lat = 37.42
        lng = -121.91
        bird = getBirdData(lat,lng,1,1).first;
        expect(haversine_distance([lat,lng],[bird["lat"],bird["lng"]],true)).to be <= 25

      end
    end
end

RSpec.describe EbirdHelper, type: :helper do

  it "given all working common names, it returns jpg images for all of them" do
      VCR.use_cassette('ebird/all_common_names_req_1') do
        VCR.use_cassette('ebird/all_common_names_req_2') do
          birds = [{"comName":"Mourning Dove","sciName":"woebfbwjbfe"},
                   {"comName":"Common Merganser","sciName":"woebfbwjbfe"},
                   {"comName":"American Coot","sciName":"woebfbwjbfe"},
                   {"comName":"Blue-winged Teal","sciName":"woebfbwjbfe"}
                 ]
          images = getImageSrc(birds);
          images.each{|image|
            expect(image.split(//).last(4).to_s).to eq ".jpg"
          }
        end
      end
    end
    it "given a mix of common names and sci names, it returns jpg images for all of them" do
        VCR.use_cassette('ebird/mix_sci_com_request_1') do
          VCR.use_cassette('ebird/mix_sci_com_request_2') do
            birds = [{"comName":"Mourning Dove","sciName":"woebfbwjbfe"},
                     {"comName":"woebfbwjbfe","sciName":"branta bernicla"},
                     {"comName":"American Coot","sciName":"woebfbwjbfe"},
                     {"comName":"woebfbwjbfe","sciName":"larus argentatus"}
                   ]

            images = getImageSrc(birds);
            images.each{|image|
              expect(image.split(//).last(4).to_s).to eq ".jpg"
            }
          end
        end
      end
      it "given a mix of common name , scir birds and a hybrid, it should return images for all but the hybrid" do
          VCR.use_cassette('ebird/mix_sci_hyb_com_req_1') do
            VCR.use_cassette('ebird/mix_sci_hyb_com_req_2') do
              birds = [{"comName":"Mourning Dove","sciName":"woebfbwjbfe"},
                       {"comName":"woebfbwjbfe","sciName":"branta bernicla"},
                       {"comName":"American Coot","sciName":"woebfbwjbfe"},
                       {"comName":"Common x Barrow's Goldeneye (hybrid)","sciName":"Bucephala clangula x islandica"}
                     ]

              images = getImageSrc(birds);
              images[0..2].each{|image|
                expect(image.split(//).last(4).to_s).to eq ".jpg"
              }
              expect(images[3]).to eq nil
            end
          end
        end


end
