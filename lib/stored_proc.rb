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
class StoredProc 
  
  def self.install(proc)
    puts "Installing #{proc}"
    sql = IO.readlines("#{source_path}/#{proc}.sql")
    sql = sql.join('')
    ActiveRecord::Base.connection.execute(sql)
  end
  
  def self.install_all
    Dir.glob("#{source_path}/*.sql").each { |path|
      puts "Installing #{path}"
      if path =~ /db\/procedures\/(sp_.*).sql$/
        install($1)
      end
    }
  end
  
  def self.exec(proc)
    puts "Running #{proc}"
    start = Time.new
    ActiveRecord::Base.connection.execute("SELECT #{proc}")
    finish = Time.new
    
    puts "Complete (#{finish - start}s)"
  end
  
private
  def self.source_path()
    return "#{RAILS_ROOT}/db/procedures"
  end
end