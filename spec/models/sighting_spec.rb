require 'rails_helper'
require 'vcr'

RSpec.describe Sighting, :type => :model do
  it "pulls data from ebird" do

    Sighting.stub(:add_bird_photos).and_return(true)
    VCR.use_cassette('ebird/sighting_update_from_ebird') do
      Sighting.update_from_ebird()
      expect expect(true).to be(true)
    end
  end
end
