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

class RawLine < ActiveRecord::Base
  
  def self.exec_normalize_subnet
    log("Normalizing subnets")
    StoredProc.exec('sp_normalize_subnet()')
  end

  def self.exec_normalize_period
    log("Normalizing periods")
    StoredProc.exec('sp_normalize_period()')
  end

  def self.exec_normalize_vhost
    log("Normalizing vhosts")
    StoredProc.exec('sp_normalize_vhost()')
  end

  def self.exec_normalize_path
    log("Normalizing paths")
    StoredProc.exec('sp_normalize_path()')
  end

  def self.exec_link_source_period
    log("Linking sources to periods")
    StoredProc.exec('sp_link_source_period()')
  end


private
  def self.log(msg)
    puts msg
  end
end
