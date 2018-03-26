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

ActiveRecord::Schema.define(version: 20180323155635) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "foundations", force: :cascade do |t|
    t.string "name"
    t.string "logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "geos", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.bigint "foundation_id"
    t.bigint "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["foundation_id"], name: "index_investments_on_foundation_id"
    t.index ["project_id"], name: "index_investments_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "ngo"
    t.string "focus_area"
    t.string "main_contact"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects_geos", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "geo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["geo_id"], name: "index_projects_geos_on_geo_id"
    t.index ["project_id"], name: "index_projects_geos_on_project_id"
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
    t.integer "foundation_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["foundation_id"], name: "index_users_on_foundation_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "installments", "investments"
  add_foreign_key "investments", "foundations"
  add_foreign_key "investments", "projects"
  add_foreign_key "projects_geos", "geos"
  add_foreign_key "projects_geos", "projects"
  add_foreign_key "users", "foundations"
end
