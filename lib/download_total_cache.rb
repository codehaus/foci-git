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

class DownloadTotalCache < ElementCache
  
  def preload
  end
  
  def logger=(logger)
    #Nothing to do
  end

  def mark_changed(download_total)
    internal_mark_changed([ download_total.vhost_id, download_total.period_id, download_total.path_id ])
  end
  
  def find_by_vhost_id_and_period_id_and_path_id(vhost_id, period_id, path_id)
    key = [ vhost_id, period_id, path_id ]
    download_total = load_cache(key)
    
    return download_total if download_total
    
    download_total = DownloadTotal.find_by_vhost_id_and_period_id_and_path_id(vhost_id, period_id, path_id)
    if not download_total
      download_total = DownloadTotal.new
      download_total.vhost_id = vhost_id
      download_total.period_id = period_id
      download_total.path_id = path_id
      download_total.count = 0
      download_total.bytes_stddev = 0
      download_total.bytes_total = 0
      download_total.bytes_average = 0
      #puts "Created new #{download_total}"
    end
    save_cache(key, download_total)
    return download_total
  end
  
  def transaction
    DownloadTotal.transaction do
      yield
    end
  end
  
  
end