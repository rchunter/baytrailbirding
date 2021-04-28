class CreateSightings < ActiveRecord::Migration[6.1]
  def change
    create_table :sightings do |t|

      # again, Ebird uses camel, the data is from ebird, so I'm sticking with camel

      t.string :speciesCode
      t.string :locName
      t.datetime :obsDt
      t.integer :howMany
      t.float :lat
      t.float :lng
      t.boolean :notable

      t.index [:speciesCode, :obsDt, :lat, :lng, :howMany], unique: true, name: 'sighting_index'

      t.timestamps
    end
  end
end
