class Bird < ApplicationRecord

  validates :ebirdSpeciesCode,  uniqueness: true

end
