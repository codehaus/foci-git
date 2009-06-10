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
    @worker = MiddleMan.worker(:prefixing_worker)
    @job_key = Time.now.to_i.to_s
    @worker.enq_load_test_prefix_data(:job_key => @job_key)

    render :template => '/prefix/progress'
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
    @finish = Chronic.parse("11:59:59pm", :now => Chronic.parse('1 month after',
                                                        :now => @start)) - 86400
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
    
    cache_mutex("basic.cache") do
      return render( :layout => false )
    end
  end

  # POST /prefix/data
  def data
    worker = MiddleMan.worker(:prefixing_worker)
    @records = worker.ask_result(params[:job_key] + '_result')

    if @records.nil?
      render :template => "prefix/not_found"
    elsif @records.class == String
      render :text => @records
    else
      render :layout => false
    end
  end

  def progress
    puts params.inspect
    prefix = params[:prefix].downcase
    host = params[:host]
    period = params[:period] || Chronic.parse('now').strftime('%b %Y')
    render(:text => 'illegal prefix') if prefix !~ /^[a-z0-9\.\-\/]+$/

    puts "Looking for host: #{host}"
    vhost = Vhost.find_by_host(host)
    render(:text => 'illegal host') if not vhost

    start = Chronic.parse("12am", :now => Chronic.parse("1 #{period}"))
    finish = Chronic.parse("11:59:59pm", :now => Chronic.parse('1 month after',
                                                        :now => start)) - 86400
    puts "Prefix search: #{prefix}"
    data = Hash.new
    data[:prefix] = prefix
    data[:vhost] = vhost.host
    data[:period] = period
    data[:sql_args] = [ "/#{prefix}/%", start, finish ]
    
    @worker = MiddleMan.worker(:prefixing_worker)
    @job_key = prefix + '_' +  data[:vhost].gsub('.', '-') + '_' +
               period.gsub(' ', '-').downcase!
    @worker.enq_load_prefix_data :job_key => @job_key, :args => data
  end
  
  # Updates the worker and job statuses, until the job that the user initiated
  # is finished, then it redirects the user to results.
  def ajax_update
    worker = MiddleMan.worker(:prefixing_worker)
    user_key = params[:user_key] # Key of the job that the user initiated.
    job_key = user_key.nil? ? '1' : worker.ask_result('current_job_key')
    result = user_key.nil? ? 'status' : job_key + '_status'
    text = worker.ask_result(result)

    if !user_key.nil? && user_key.eql?(job_key) &&
       text.eql?('Job finished.')
      render :text => '/prefix/data?job_key=' + job_key
    else
      render :text => text
    end
  end
end

