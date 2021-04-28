require 'rails_helper'

RSpec.describe LocationFacility, :type => :model do
  subject {
    described_class.new()
  }

  describe "Model Validations" do
    it "is valid with valid attributes" do
    	expect(subject).to be_valid
    end

    it "is not valid without a name" do
    	subject.name = nil
    	expect(subject).to_not be_valid
    end

    it "is not valid without a description" do
    	subject.description = nil
    	expect(subject).to_not be_valid
    end

    it "is not valid without a latitude" do
      subject.latitude = nil
      expect(subject).to_not be_valid
    end

    it "is not valid without a longitude" do
      subject.longitude = nil
      expect(subject).to_not be_valid
    end
    it "belongs too location" do
      should respond_to(:locations)
    end
    it "belongs too facilitie" do
      should respond_to(:facilities)
    end
  end
end
