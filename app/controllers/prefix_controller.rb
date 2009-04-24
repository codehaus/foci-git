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
require 'chronic'

class PrefixController < ApplicationController
  
  def simple
    @prefix = params[:prefix]
    @host = params[:host]
    @period = params[:period] || Chronic.parse('now').strftime('%b %Y')
  end
  
  def simple_test
    cache_mutex('simple_test') { 
      logger.info "Sleeping"
      sleep((params[:sleep] || '5').to_f)
      logger.info "Done"
      render :text => (params[:message] || 'whatever')
    }
  end
  
  def simple_data
    puts params.inspect
    @prefix = params[:prefix].downcase
    @host = params[:host]
    @period = params[:period] || Chronic.parse('now').strftime('%b %Y')
    return render( :text => 'illegal prefix' ) if @prefix !~ /^[a-z0-9\.\-\/]+$/
    puts "Looking for host: #{@host}"
    @vhost = Vhost.find_by_host(@host)
    return render( :text => 'illegal host' ) if not @vhost

    #gem 'chronic'
    #require 'chronic'
    #@period = 'dec 2008'
    @start = Chronic.parse("12am", :now => Chronic.parse("1 #{@period}"))
    @finish = Chronic.parse("11:59:59pm", :now => Chronic.parse('1 month after', :now => @start)) - 86400
    puts "Prefix search: #{@prefix}"
    @sql = <<-EOF
    select
      to_char(pd.start, 'YYYYMM') AS period_text,
      SUM(response_count) AS response_count,
      SUM(response_bytes) AS response_bytes,
      SUM(response_time) / SUM(response_count) AS average_response_time,
      SUM(response_bytes) / SUM(response_count) AS average_response_bytes, 
      p.path AS path_text
    from 
      path_totals pt, 
      paths p, 
      periods pd
    where 
          vhost_id = (select id from vhosts where host = '#{@vhost.host}') 
      and pt.path_id = p.id 
      and p.path LIKE ?
      and pd.id = pt.period_id
      and pd.start BETWEEN ? AND ?
    group by 
      to_char(pd.start, 'YYYYMM'), 
      p.path
    order by  
      to_char(pd.start, 'YYYYMM') DESC, 
      sum(response_bytes) desc;
EOF
    @sql_args = [ "/#{@prefix}/%", @start, @finish ]
    
    cache_mutex("basic.cache") {
      return render( :layout => false )
    }
  end
end
