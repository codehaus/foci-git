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

class CreateSources < ActiveRecord::Migration
  def self.up
    create_table :sources do |t|
      t.column :url, :string, :limit => 4096, :null => false
      t.column :loaded, :boolean, :null => false
      t.column :size, :integer, :null => false, :default => 0
    end

    Path.connection.execute("CREATE UNIQUE INDEX SOURCES_URL_UK ON SOURCES(URL)")
  end

  def self.down
    drop_table :sources
  end
end
