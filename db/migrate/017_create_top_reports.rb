################################################################################
#  Copyright 2007-2008 Codehaus Foundation
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
################################################################################

class CreateTopReports < ActiveRecord::Migration
  def self.up
    
    create_table :top_report_types do |t|
      t.string :key
      t.string :title
      t.string :description
    end
    
    create_table :top_reports do |t|
      t.integer :top_report_type_id
      t.integer :sort
      t.string :title
      t.string :description
      t.string :url
      t.string :data, :limit => 65000 #YAML data field
      t.timestamps
    end
    
  end

  def self.down
    drop_table :top_reports
    drop_table :top_report_types
  end
end
