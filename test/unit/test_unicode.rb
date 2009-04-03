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

require File.dirname(__FILE__) + '/../test_helper'
require 'iconv'

class DownloadTotalsTest < Test::Unit::TestCase
  fixtures :download_totals
  DATA = '63.246.7.187 - - [22/Mar/2008:09:32:59 -0500] "\xb8:\xcb /user/messages/414?root=haus/codehaus/mevenide HTTP/1.1" 502 413 "http://www.nationallywager.com/betting-on-horse-racing-for.html" "Mozilla/4.0 (compatible; MSIE 5.5; Windows 98; KITV4.7 Wanadoo)" archive.hausfoundation.org 0'
  # Replace this with your real tests.
  def test_iconv
    converter = Iconv.new('UTF-8//IGNORE//TRANSLIT', 'UTF-8') 
    puts converter.iconv(DATA)
  end
end

