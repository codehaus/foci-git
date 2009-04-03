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

class VhostsController < ApplicationController
  
  def index
    @vhost = Vhost.find_by_host(params[:vhost])
    #Should check that the vhost is a sub vhost of the @core_vhost
    
    
    @period = nil
    
    if params.has_key?(:period)
      @period = Period.find_by_id(params[:period])
      if not @period
        render '/core/no_such_period'
        return
      end
    end

    if not @vhost and not @period
      render :file => RAILS_ROOT + '/app/views/search/index.rhtml'
      return
    end
    
    @totals = PathTotal.totals_for_vhost_period( @vhost, @period  )
    
    @recent_periods = Period.find_recent(@vhost)
    
  end
  
  
end
