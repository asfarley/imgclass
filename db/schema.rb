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

ActiveRecord::Schema.define(version: 20170903074646) do

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "image_label_sets", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.boolean  "bounding_box_mode"
    t.string   "name"
    t.index ["user_id"], name: "index_image_label_sets_on_user_id"
  end

  create_table "image_labels", force: :cascade do |t|
    t.integer  "image_id"
    t.integer  "label_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "job_id"
    t.string   "target"
    t.index ["image_id"], name: "index_image_labels_on_image_id"
    t.index ["label_id"], name: "index_image_labels_on_label_id"
    t.index ["user_id"], name: "index_image_labels_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.string   "url"
    t.integer  "image_label_set_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["image_label_set_id"], name: "index_images_on_image_label_set_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.integer  "image_label_set_id"
    t.integer  "user_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["image_label_set_id"], name: "index_jobs_on_image_label_set_id"
    t.index ["user_id"], name: "index_jobs_on_user_id"
  end

  create_table "labels", force: :cascade do |t|
    t.string   "text"
    t.integer  "image_label_set_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["image_label_set_id"], name: "index_labels_on_image_label_set_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
