class CreateBirds < ActiveRecord::Migration[6.1]
  def change
    create_table :birds do |t|

      # there should be snake case, but the ebird api uses camel
      # so I've stuck with camel for now
      # we can change his if need be
      # but this made more sense to me when I was writing it

      t.string :ebirdSpeciesCode, unique: true

      t.string :comName
      t.string :sciName
      t.string :photoURL

      t.timestamps
    end
  end
end
