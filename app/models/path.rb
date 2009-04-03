################################################################################
#  Copyright 2007-2008 Codehaus Foundation                                     #
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

# For normalizing URIs
gem 'addressable'
require 'addressable/uri'


class Path < ActiveRecord::Base
  has_many :download_totals
  
  def to_s
    "Path[id=#{id},path=#{path}]"
  end
  
  def self.normalize_path(path)
    begin
      uri = Addressable::URI.heuristic_parse(path)
      uri = uri.normalize.to_s
      uri = uri.gsub(/\/+/, '/')
      uri = uri.split('#').first
      uri = uri.downcase
      return uri
    rescue
      puts "Failed to parse: #{path}"
      return path
    end
  end
end
