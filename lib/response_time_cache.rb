################################################################################
#  Copyright 2007 Codehaus Foundation                                          #
#                                                                              #
#  Licensed under the Apache License, Version 2.0 (the "License");             #
#  you may not use this file except in compliance with the License.            #
#  You may obtain a copy of the License at                                     #
#                                                                              #
#     http://www.apache.org/licenses/LICENSE-2.0                               #
#                                                                              #
#  Unless required by applicable law or agreed to in writing, software         #
#  distributed under the License is distributed on an "AS IS" BASIS,           #
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    #
#  See the License for the specific language governing permissions and         #
#  limitations under the License.                                              #
################################################################################

class ResponseTimeCache < ElementCache
  
  def preload
  end
  
  def logger=(logger)
    #Nothing to do
  end

  def mark_changed(response_time)
    internal_mark_changed([ response_time.vhost_id, response_time.period_id, response_time.path_id ])
  end
  
  def find_by_vhost_id_and_period_id_and_path_id(vhost_id, period_id, path_id)
    key = [ vhost_id, period_id, path_id ]
    response_time = load_cache(key)
    
    return response_time if response_time
    
    response_time = ResponseTime.find_by_vhost_id_and_period_id_and_path_id(vhost_id, period_id, path_id)
    if not response_time
      response_time = ResponseTime.new
      response_time.vhost_id = vhost_id
      response_time.period_id = period_id
      response_time.path_id = path_id
      response_time.count = 0
      response_time.response_time = 0
    end
    save_cache(key, response_time)
    return response_time
  end
  
  def transaction
    ResponseTime.transaction do
      yield
    end
  end
  
  
end