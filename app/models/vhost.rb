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

class Vhost < ActiveRecord::Base
  acts_as_tree
  
  has_many :path_totals
  has_many :subnet_totals

  
  def child_vhosts
    Vhost.find( :all, :conditions => [ 'parent_id = ?', id ], :order => 'host' )
  end
  
  def parent_vhost
    parent
  end
  
  def self.find_best_host(host)
    puts "LOOKING AT #{host}"
    return nil if not host 
    return nil if host.strip.blank?

    vh = Vhost.find_by_host(host)
    return vh if vh
    
    return find_best_host(host.split('.')[1..-1].join('.'))
  end
  
  def before_create
    reset_parent_id
  end
  
  def dcs
    return host.split('.')
  end
  
  def reset_parent_id
    pieces = host.split(".")
    
    logger.debug "Checking #{host}"
    if pieces.length > 1 
      parent_vhost_host = pieces[1..-1].join(".")
      logger.debug " Looking for #{parent_vhost_host}"
      parent_vhost = Vhost.find_by_host(parent_vhost_host)
      
      if parent_vhost
        logger.debug " Found parent: #{parent_vhost.host}"
        self.parent = parent_vhost
      end
    end
  end
  
  def host_brief
    pieces = host.split(".")[0]
  end
  
  def to_s
    "Vhost[id=#{id}, host=#{host}]"
  end
end
