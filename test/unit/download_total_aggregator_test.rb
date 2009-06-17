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

class Foci::Aggregators::DownloadTotalAggregatorTest < ActiveSupport::TestCase
  all_fixtures

  # Replace this with your real tests.
  def test_aggregation
    dta = Foci::Aggregators::DownloadTotalAggregator.new
    
    parser = Foci::LogParser.new
    
    fields = parser.parse_line('193.34.112.161 - - [06/May/2007:07:04:47 -0500] "GET /" 200 22600 "-" "-" dist.co... 25')
    
    vhost = Vhost.find_by_host('dist.example.com')
    assert_not_nil vhost
    
    period = Period.find_by_name('Dec 2004')
    assert_not_nil period

    dta.process(vhost, period, fields)
  end
end
