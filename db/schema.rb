# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 18) do

  create_table "bdrb_job_queues", :force => true do |t|
    t.text     "args"
    t.string   "worker_name"
    t.string   "worker_method"
    t.string   "job_key"
    t.integer  "taken"
    t.integer  "finished"
    t.integer  "timeout"
    t.integer  "priority"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.string   "tag"
    t.string   "submitter_info"
    t.string   "runner_info"
    t.string   "worker_key"
    t.datetime "scheduled_at"
  end

  create_table "path_totals", :force => true do |t|
    t.integer "vhost_id",                                                           :null => false
    t.integer "period_id",                                                          :null => false
    t.integer "path_id",                                                            :null => false
    t.integer "response_count",        :limit => 8,                                 :null => false
    t.integer "response_bytes",        :limit => 8,                                 :null => false
    t.integer "response_bytes_square", :limit => 30, :precision => 30, :scale => 0, :null => false
    t.integer "response_time",         :limit => 8,                                 :null => false
    t.integer "response_time_square",  :limit => 30, :precision => 30, :scale => 0, :null => false
  end

  add_index "path_totals", ["path_id", "period_id", "vhost_id"], :name => "index_path_totals_on_path_id_and_period_id_and_vhost_id"
  add_index "path_totals", ["path_id", "period_id", "vhost_id"], :name => "index_path_totals_on_period_id_and_path_id_and_vhost_id"
  add_index "path_totals", ["path_id", "period_id", "vhost_id"], :name => "index_path_totals_on_vhost_id_and_period_id_and_path_id"

  create_table "paths", :force => true do |t|
    t.string "path", :null => false
  end

  add_index "paths", ["path"], :name => "paths_like_path_uk", :unique => true
  add_index "paths", ["path"], :name => "paths_path_uk", :unique => true

  create_table "period_group_periods", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "period_groups", :force => true do |t|
    t.string   "name"
    t.datetime "start",      :null => false
    t.datetime "finish",     :null => false
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "periods", :force => true do |t|
    t.string   "name",     :null => false
    t.datetime "start",    :null => false
    t.datetime "finish",   :null => false
    t.integer  "duration", :null => false
  end

  create_table "raw_lines", :force => true do |t|
    t.integer  "source_id"
    t.string   "ip",              :limit => nil
    t.string   "subnet",          :limit => nil
    t.string   "auth"
    t.string   "username"
    t.datetime "datetime"
    t.integer  "period_id"
    t.string   "request",         :limit => 4096
    t.string   "method",          :limit => 10
    t.string   "path",            :limit => 4096
    t.string   "path_normalized", :limit => 4096
    t.integer  "path_id"
    t.integer  "status"
    t.integer  "bytecount"
    t.string   "host"
    t.integer  "vhost_id"
    t.integer  "duration"
  end

  create_table "rejected_lines", :force => true do |t|
    t.integer  "source_id",                    :null => false
    t.integer  "line_number",                  :null => false
    t.string   "line_text",   :limit => 65535, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "source_periods", :force => true do |t|
    t.integer  "source_id",  :null => false
    t.integer  "period_id",  :null => false
    t.integer  "line_count", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sources", :force => true do |t|
    t.string  "url",        :limit => 4096,                :null => false
    t.boolean "loaded",                                    :null => false
    t.integer "size",                       :default => 0, :null => false
    t.integer "line_count",                 :default => 0
    t.string  "host",                                      :null => false
    t.string  "name"
  end

  add_index "sources", ["host", "name"], :name => "sources_host_name_uk", :unique => true
  add_index "sources", ["host", "url"], :name => "sources_host_url_uk", :unique => true

  create_table "subnet_totals", :force => true do |t|
    t.integer "vhost_id",                                                            :null => false
    t.integer "period_id",                                                           :null => false
    t.string  "subnet",                :limit => nil,                                :null => false
    t.integer "response_count",        :limit => 8,                                  :null => false
    t.integer "response_bytes",        :limit => 8,                                  :null => false
    t.integer "response_bytes_square", :limit => 30,  :precision => 30, :scale => 0, :null => false
  end

  add_index "subnet_totals", ["period_id", "subnet", "vhost_id"], :name => "index_subnet_totals_on_period_id_and_vhost_id_and_subnet"
  add_index "subnet_totals", ["period_id", "subnet", "vhost_id"], :name => "index_subnet_totals_on_subnet_and_period_id_and_vhost_id"

  create_table "top_report_types", :force => true do |t|
    t.string "key"
    t.string "title"
    t.string "description"
  end

  create_table "top_reports", :force => true do |t|
    t.integer  "top_report_type_id"
    t.integer  "sort"
    t.string   "title"
    t.string   "description"
    t.string   "url"
    t.string   "data",               :limit => 65000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vhosts", :force => true do |t|
    t.string  "host",                               :null => false
    t.integer "parent_id"
    t.boolean "aggregate_paths", :default => false, :null => false
  end

  add_index "vhosts", ["host"], :name => "vhosts_host_uk", :unique => true

  add_foreign_key "path_totals", ["vhost_id"], "vhosts", ["id"], :name => "path_totals_vhost_id_fkey"
  add_foreign_key "path_totals", ["period_id"], "periods", ["id"], :name => "path_totals_period_id_fkey"
  add_foreign_key "path_totals", ["path_id"], "paths", ["id"], :name => "path_totals_path_id_fkey"

  add_foreign_key "raw_lines", ["source_id"], "sources", ["id"], :name => "raw_lines_source_id_fkey"
  add_foreign_key "raw_lines", ["period_id"], "periods", ["id"], :name => "raw_lines_period_id_fkey"
  add_foreign_key "raw_lines", ["path_id"], "paths", ["id"], :name => "raw_lines_path_id_fkey"
  add_foreign_key "raw_lines", ["vhost_id"], "vhosts", ["id"], :name => "raw_lines_vhost_id_fkey"

  add_foreign_key "rejected_lines", ["source_id"], "sources", ["id"], :name => "rejected_lines_source_id_fkey"

  add_foreign_key "source_periods", ["source_id"], "sources", ["id"], :name => "source_periods_source_id_fkey"
  add_foreign_key "source_periods", ["period_id"], "periods", ["id"], :name => "source_periods_period_id_fkey"

  add_foreign_key "subnet_totals", ["vhost_id"], "vhosts", ["id"], :name => "subnet_totals_vhost_id_fkey"
  add_foreign_key "subnet_totals", ["period_id"], "periods", ["id"], :name => "subnet_totals_period_id_fkey"

  add_foreign_key "top_reports", ["top_report_type_id"], "top_report_types", ["id"], :name => "top_reports_top_report_type_id_fkey"

  add_foreign_key "vhosts", ["parent_id"], "vhosts", ["id"], :name => "vhosts_parent_id_fkey"

end
