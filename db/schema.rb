# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180419162407) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "focus_area_translations", force: :cascade do |t|
    t.integer "focus_area_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["focus_area_id"], name: "index_focus_area_translations_on_focus_area_id"
    t.index ["locale"], name: "index_focus_area_translations_on_locale"
  end

  create_table "focus_areas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "geos", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "geos_projects", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "geo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["geo_id"], name: "index_geos_projects_on_geo_id"
    t.index ["project_id"], name: "index_geos_projects_on_project_id"
  end

  create_table "installments", force: :cascade do |t|
    t.text "task"
    t.date "deadline"
    t.string "status", default: "locked"
    t.integer "amount", default: 0
    t.bigint "investment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["investment_id"], name: "index_installments_on_investment_id"
  end

  create_table "investments", force: :cascade do |t|
    t.boolean "completed", default: false
    t.bigint "organisation_id"
    t.bigint "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "ongoing"
    t.index ["organisation_id"], name: "index_investments_on_organisation_id"
    t.index ["project_id"], name: "index_investments_on_project_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.string "name"
    t.string "logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "charity_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "main_contact"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organisation_id"
    t.bigint "focus_area_id"
    t.index ["focus_area_id"], name: "index_projects_on_focus_area_id"
    t.index ["organisation_id"], name: "index_projects_on_organisation_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.integer "organisation_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organisation_id"], name: "index_users_on_organisation_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "geos_projects", "geos"
  add_foreign_key "geos_projects", "projects"
  add_foreign_key "installments", "investments"
  add_foreign_key "investments", "organisations"
  add_foreign_key "investments", "projects"
  add_foreign_key "projects", "focus_areas"
  add_foreign_key "projects", "organisations"
  add_foreign_key "users", "organisations"
end
