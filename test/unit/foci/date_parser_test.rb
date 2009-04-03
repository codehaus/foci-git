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

class DateParserTest < Test::Unit::TestCase

  # Replace this with your real tests.
  def test_parser
    parser = Foci::Parser.new
    test_parser_equals( '20/Oct/2006:00:00:00 -0500' )
    test_parser_equals( '21/Oct/2006:00:10:00 -0800' )
    test_parser_equals( '22/Oct/2006:00:00:12 -0500' )
    test_parser_equals( '23/Oct/2006:12:58:32 -0500' )
  end
  
  def test_parser_equals(datetime)
    expected = strptime_parser(datetime)
    actual = Foci::DateParser.parse(datetime)
    puts "Expected: #{expected.strftime('%d/%b/%Y:%H:%M:%S %z')}" 
    puts "Actual:   #{actual.strftime('%d/%b/%Y:%H:%M:%S %z')}"
    #puts "Expected: #{expected.inspect}"
    #puts "Actual:   #{actual.inspect}"
    #assert expected.eql?( actual )
  end
    
  def strptime_parser(datetime)
    DateTime.strptime(datetime, "%d/%b/%Y:%H:%M:%S %z")
  end
end
