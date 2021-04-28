# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_05_041923) do

  create_table "birds", force: :cascade do |t|
    t.string "ebirdSpeciesCode"
    t.string "comName"
    t.string "sciName"
    t.string "photoURL"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "facilities", force: :cascade do |t|
    t.text "name"
    t.text "icon"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "facilities_locations", id: false, force: :cascade do |t|
    t.integer "location_id", null: false
    t.integer "facility_id", null: false
    t.index ["location_id", "facility_id"], name: "index_facilities_locations_on_location_id_and_facility_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "website"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "latitude"
    t.string "longitude"
  end

  create_table "sightings", force: :cascade do |t|
    t.string "speciesCode"
    t.string "locName"
    t.datetime "obsDt"
    t.integer "howMany"
    t.float "lat"
    t.float "lng"
    t.boolean "notable"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["speciesCode", "obsDt", "lat", "lng", "howMany"], name: "sighting_index", unique: true
  end

end
