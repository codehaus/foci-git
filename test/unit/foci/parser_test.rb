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
require File.dirname(__FILE__) + '/../../test_helper'

class ParserTest < Test::Unit::TestCase
  
  #all_fixtures

  # Replace this with your real tests.
  def test_parser
    parser = Foci::Parser.new
    line = "194.231.193.65 - - [20/Oct/2006:00:00:00 -0500] \"GET /tutorial.html HTTP/1.1\" 200 8674 \"http://xstream.codehaus.org/\" \"Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.8.0.7) Gecko/20060909 Firefox/1.5.0.7\" xstream.codehaus.org 0"
    item = parser.parse(line)
    #puts item.inspect
    assert_not_nil item
  end
end
