class CreateBirds < ActiveRecord::Migration[6.1]
  def change
    create_table :birds do |t|
      t.text :speciesCode
      t.text :comName
      t.text :sciName
      t.text :locId
      t.text :locName
      t.text :obsDt
      t.integer :howMany
      t.float :lat
      t.float :lng
      t.boolean :obsValid
      t.boolean :obsReviewed
      t.boolean :locationPrivate
      t.text :subId

      t.timestamps
    end
  end
end
