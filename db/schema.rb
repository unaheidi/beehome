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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140910035617) do

  create_table "containers", :force => true do |t|
    t.string   "container_id"
    t.integer  "image_id"
    t.integer  "ip_address_id"
    t.integer  "status"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "devices", :force => true do |t|
    t.string   "ip"
    t.string   "gateway"
    t.string   "os"
    t.string   "docker_remote_api"
    t.integer  "status"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "images", :force => true do |t|
    t.string   "repository"
    t.string   "tag"
    t.string   "image_id"
    t.string   "dockerfile_url"
    t.integer  "status"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "purpose"
  end

  create_table "ip_addresses", :force => true do |t|
    t.string   "address"
    t.string   "netmask"
    t.integer  "device_id"
    t.integer  "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
