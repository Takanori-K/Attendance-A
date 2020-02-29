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

ActiveRecord::Schema.define(version: 20200221164211) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "next_day"
    t.string "business_description"
    t.string "instructor_sign"
    t.datetime "scheduled_end_time"
    t.integer "overtime_status", default: 0
    t.string "overtime_change"
    t.string "one_month_sign"
    t.date "worked_month"
    t.integer "month_status", default: 0
    t.string "month_change"
    t.string "worked_request_sign"
    t.integer "worked_status", default: 0
    t.string "worked_change"
    t.datetime "applying_started_at"
    t.datetime "applying_finished_at"
    t.datetime "approval_started"
    t.datetime "approval_finished"
    t.datetime "denial_started"
    t.datetime "denial_finished"
    t.datetime "approval_date"
    t.string "edit_note"
    t.datetime "approval_end_time"
    t.string "approval_business_description"
    t.string "edit_next_day"
    t.string "tomorrow"
    t.string "edit_tomorrow"
    t.string "edit_request_sign"
    t.string "denial_request_sign"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.string "base_name"
    t.string "base_number"
    t.string "base_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "affiliation"
    t.datetime "basic_time", default: "2020-02-29 23:00:00"
    t.datetime "work_time", default: "2020-02-29 22:30:00"
    t.boolean "superior", default: false
    t.string "employee_number"
    t.datetime "designated_work_start_time", default: "2020-02-29 23:00:00"
    t.datetime "designated_work_end_time", default: "2020-03-01 10:00:00"
    t.string "uid"
    t.datetime "basic_work_time", default: "2020-02-29 23:00:00"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
