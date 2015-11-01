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

ActiveRecord::Schema.define(version: 20151101200454) do

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

  create_table "badges", force: :cascade do |t|
    t.string   "name"
    t.text     "criteria"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "badge_id"
  end

  create_table "contests", force: :cascade do |t|
    t.string   "email"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "devices", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "device_id"
    t.string   "status",      default: "subscribed"
    t.string   "type"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "device_type"
  end

  create_table "emp_data", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.integer  "age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "question_histories", force: :cascade do |t|
    t.integer  "owner_id"
    t.text     "clean_up",     default: [],              array: true
    t.text     "order_taking", default: [],              array: true
    t.text     "barista",      default: [],              array: true
    t.text     "selling",      default: [],              array: true
    t.text     "kitchen",      default: [],              array: true
    t.text     "bartender",    default: [],              array: true
    t.text     "service",      default: [],              array: true
    t.text     "cashier",      default: [],              array: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "question_histories", ["owner_id"], name: "index_question_histories_on_owner_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.string   "question"
    t.string   "choice_a"
    t.string   "choice_b"
    t.string   "choice_c"
    t.string   "choice_d"
    t.string   "answer"
    t.string   "genre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rpush_apps", force: :cascade do |t|
    t.string   "name",                                null: false
    t.string   "environment"
    t.text     "certificate"
    t.string   "password"
    t.integer  "connections",             default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                                null: false
    t.string   "auth_key"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "access_token"
    t.datetime "access_token_expiration"
  end

  create_table "rpush_feedback", force: :cascade do |t|
    t.string   "device_token", limit: 64, null: false
    t.datetime "failed_at",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_id"
  end

  add_index "rpush_feedback", ["device_token"], name: "index_rpush_feedback_on_device_token", using: :btree

  create_table "rpush_notifications", force: :cascade do |t|
    t.integer  "badge"
    t.string   "device_token",      limit: 64
    t.string   "sound",                        default: "default"
    t.string   "alert"
    t.text     "data"
    t.integer  "expiry",                       default: 86400
    t.boolean  "delivered",                    default: false,     null: false
    t.datetime "delivered_at"
    t.boolean  "failed",                       default: false,     null: false
    t.datetime "failed_at"
    t.integer  "error_code"
    t.text     "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "alert_is_json",                default: false
    t.string   "type",                                             null: false
    t.string   "collapse_key"
    t.boolean  "delay_while_idle",             default: false,     null: false
    t.text     "registration_ids"
    t.integer  "app_id",                                           null: false
    t.integer  "retries",                      default: 0
    t.string   "uri"
    t.datetime "fail_after"
    t.boolean  "processing",                   default: false,     null: false
    t.integer  "priority"
    t.text     "url_args"
    t.string   "category"
  end

  add_index "rpush_notifications", ["delivered", "failed"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))", using: :btree

  create_table "scores", force: :cascade do |t|
    t.integer  "service",      default: 0
    t.integer  "kitchen",      default: 0
    t.integer  "bartender",    default: 0
    t.integer  "barista",      default: 0
    t.integer  "order_taking", default: 0
    t.integer  "cashier",      default: 0
    t.integer  "clean_up",     default: 0
    t.integer  "selling",      default: 0
    t.integer  "owner_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "quiz_count",   default: 0
    t.float    "quiz_score",   default: 0.0
  end

  add_index "scores", ["owner_id"], name: "index_scores_on_owner_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                            default: "",          null: false
    t.string   "encrypted_password",               default: "",          null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0,           null: false
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
    t.string   "address",                          default: "Singapore"
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
    t.float    "latitude"
    t.float    "longitude"
    t.string   "referral_id"
    t.integer  "referred_users",                   default: 0
    t.text     "obtained_badges",                  default: [],                       array: true
    t.string   "referred_by"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "verified",                         default: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["contact_number"], name: "index_users_on_contact_number", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "notifications", "users", column: "receiver_id"
  add_foreign_key "notifications", "users", column: "sender_id"
  add_foreign_key "posts", "users", column: "owner_id"
  add_foreign_key "question_histories", "users", column: "owner_id"
  add_foreign_key "scores", "users", column: "owner_id"
end
