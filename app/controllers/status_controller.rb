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

class StatusController < ApplicationController
  before_filter :filter_lookup_period, :except => [ :index ]
  
  def index
    @period = Period.find_by_start(Period.maximum('start'))
  end
  
  def sources_data
    @sources = 
    Source.find_by_sql(<<-EOF
    SELECT S.* 
    FROM SOURCES S 
    WHERE S.ID IN (SELECT SOURCE_ID FROM SOURCE_PERIODS WHERE PERIOD_ID = #{@period.id})
    ORDER BY S.NAME
EOF
    )
    
    render :layout => false
  end
  
  def totals_data
    totals_for_period = PathTotal.totals_for_period(@period)
    
    if not totals_for_period.empty?
      @totals = totals_for_period.first 
      render :layout => false
    else
      render :layout => false, :action => 'empty_data'
    end
  end
  
  def domains_data
    @domains = PathTotal.top_vhosts(@period)
    
    if @domains.empty?
      render :layout => false, :action => 'empty_data'
    else
      render :layout => false
    end
  end
  
  def paths_data
    @paths = PathTotal.top_paths(@period)

    if @paths.empty?
      render :layout => false, :action => 'empty_data'
    else
      render :layout => false
    end
  end
  
private
  def filter_lookup_period
    @period = Period.find(params[:period_id].to_i)
    return false unless @period 
  end
end
