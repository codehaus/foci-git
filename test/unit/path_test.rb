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

class PathTest < Test::Unit::TestCase
  all_fixtures

  def test_first
    p = Path.find(:first)
    assert_not_nil p
  end
  
  def test_normalize
    assert_normalize '/index.html', '/INDEX.HTML'
    assert_normalize '/index.html', '/INDEX.HTML#A'
    assert_normalize '/index.html', '/./INDEX.HTML'
    assert_normalize '/index.html', '////INDEX.HTML'
  end
  
  
private
  def assert_normalize(expected, input)
    assert_equal( expected, Path.normalize_path(input), "Path.normalize_path(#{input})" )
  end
  
end
