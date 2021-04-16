class Bird < ApplicationRecord
    validates_presence_of :speciesCode
    validates_presence_of :comName 
    validates_presence_of :sciName 
    validates_presence_of :howMany 
end