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

class CreateSubnetTotals < ActiveRecord::Migration
  def self.up
    create_table :subnet_totals do |t|
      t.column :vhost_id, :integer, :null => false
      t.column :period_id, :integer, :null => false
      t.column :subnet, :cidr, :null => false
      
      t.column :response_count, :bigint, :null => false
      t.column :response_bytes, :bigint, :null => false
      t.column :response_bytes_square, :decimal, :precision => 30, :scale => 0, :null => false
    end

    # This will be better for selectivity
    add_index(:subnet_totals, [ :subnet, :period_id, :vhost_id ])
    
    # Just a basic index when we're looking for vhosts/period data
    add_index(:subnet_totals, [ :period_id, :vhost_id, :subnet ])
    
  end

  def self.down
    drop_table :subnet_totals
  end
end
