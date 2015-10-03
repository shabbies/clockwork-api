# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150930163831) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token",                null: false
    t.datetime "expires_at"
    t.integer  "user_id",                     null: false
    t.boolean  "active",       default: true, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "api_keys", ["access_token"], name: "index_api_keys_on_access_token", unique: true, using: :btree
  add_index "api_keys", ["user_id"], name: "index_api_keys_on_user_id", using: :btree

  create_table "emp_data", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.integer  "age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "matched", id: false, force: :cascade do |t|
    t.integer "post_id"
    t.integer "user_id"
    t.string  "status",      default: "applied"
    t.float   "user_rating", default: 0.0
  end

  add_index "matched", ["post_id", "user_id"], name: "by_user_and_post", unique: true, using: :btree

  create_table "matchings", force: :cascade do |t|
    t.integer  "applicant_id"
    t.integer  "post_id"
    t.string   "status",       default: "pending"
    t.integer  "user_rating"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "comments"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.string   "content"
    t.string   "status",      default: "unread"
    t.string   "avatar_path"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "post_id"
  end

  add_index "notifications", ["receiver_id"], name: "index_notifications_on_receiver_id", using: :btree
  add_index "notifications", ["sender_id"], name: "index_notifications_on_sender_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.text     "header"
    t.string   "company"
    t.float    "salary"
    t.text     "description"
    t.string   "location"
    t.date     "posting_date"
    t.date     "job_date"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "owner_id"
    t.string   "status",       default: "listed"
    t.date     "expiry_date"
    t.integer  "duration"
    t.string   "start_time"
    t.date     "end_date"
    t.string   "end_time"
    t.string   "avatar_path"
    t.string   "pay_type",     default: "hour"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                            default: "", null: false
    t.string   "encrypted_password",               default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "account_type"
    t.string   "username"
    t.string   "authentication_token"
    t.string   "facebook_id"
    t.string   "address"
    t.integer  "contact_number"
    t.string   "date_of_birth"
    t.string   "avatar_path"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "gender",                 limit: 1
    t.string   "nationality"
    t.integer  "good_rating",                      default: 0
    t.integer  "neutral_rating",                   default: 0
    t.integer  "bad_rating",                       default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "notifications", "users", column: "receiver_id"
  add_foreign_key "notifications", "users", column: "sender_id"
  add_foreign_key "posts", "users", column: "owner_id"
end
