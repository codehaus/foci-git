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

class CreateRawLines < ActiveRecord::Migration
  def self.up
    create_table :raw_lines do |t|
      t.integer :source_id
      t.column :ip, :inet
      t.column :subnet,    :cidr
      t.string :auth
      t.string :username
      t.timestamp :datetime
        t.integer :period_id
      t.string :request, :limit => 4096
      t.string :method, :limit => 10
      t.string :path, :limit => 4096
      t.string :path_normalized, :limit => 4096
        t.integer :path_id
      t.integer :status
      t.integer :bytecount
      t.string :host
        t.integer :vhost_id
      t.integer :duration
    end
    

  end

  def self.down
    drop_table :raw_lines
  end
end
