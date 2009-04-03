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

class ChartsController < ApplicationController
  before_filter :filter_interval

  def index
  end
  
  def sources_per_day
    @graph = open_flash_chart_object(500,250, '/charts/sources_per_day_data', false, '/')     
  end
  
  def sources_per_day_data
    g = Graph.new
    g.title("Sources loaded per day (#{@interval})", '{font-size: 23px; font-family: verdana}')
    g.set_bg_color('#FFFFFF')
    g.line_dot( 2, 4, '#818D9D', 'Source Count', 10 )
    g.set_y_max(24)
    g.set_y_label_steps(4)

    sql = <<-EOF
SELECT P.*, (SELECT COUNT(*) FROM SOURCE_PERIODS SP WHERE SP.PERIOD_ID = P.ID) AS SOURCE_COUNT
FROM PERIODS P
WHERE P.START > NOW() - INTERVAL '#{@interval}'
ORDER BY P.START
EOF
    data = []
    x_labels = []
    Period.find_by_sql(sql).each { |period|
      x_labels << period.start.strftime('%Y-%m-%d')
      data << period.source_count
    }
    
    g.set_data(data)
    g.set_x_labels(x_labels)
    g.set_x_label_style('100%', color='', orientation=0, step=-1, grid_color='')
    #set_x_label_style(size, color='', orientation=0, step=-1, grid_color='')
    
    if x_labels.empty?
      x_steps = 1
    else
      x_steps = (20 / x_labels.length).to_i #Max of 20 steps
    end
    g.set_x_label_style(10, '#164166', 0, x_steps, '#818D9D' )
       
    render :text => g.render
  end

    def historical_load
      @graph = open_flash_chart_object(500,250, '/charts/historical_load_data', false, '/')     
    end

    def historical_load_data
      g = Graph.new
      g.title("Historical Load (#{@interval})", '{font-size: 23px; font-family: verdana}')
      g.set_bg_color('#FFFFFF')

      sql = <<-EOF
       SELECT
          P.START,
          SUM(response_count) AS response_count, 
          SUM(response_bytes) AS response_bytes,
          SUM(response_bytes) / SUM(response_count) AS average_response_bytes,
          SUM(response_time) / SUM(response_count) AS average_response_time
        FROM PATH_TOTALS PT, PERIODS P
        WHERE 
            PT.PERIOD_ID = P.ID
        AND P.START > NOW() - INTERVAL '#{@interval}'
        GROUP BY P.START
        ORDER BY P.START
  EOF
      
      x_labels = []
      data_response_count = []
      data_response_bytes = []
      #data_average_response_bytes = []
      #data_average_response_time = []
      
      Period.find_by_sql(sql).each { |period|
        x_labels << period.start.strftime('%Y-%m-%d')
        data_response_count << period.response_count.to_f / 1000
        data_response_bytes << period.response_bytes.to_f / 1024 / 1024 / 1024
        #data_average_response_bytes << period.average_response_bytes
        #data_average_response_time << period.average_response_time
      }

      g.set_x_labels(x_labels)
      
      g.set_data(data_response_count)
      g.set_y_legend( 'Hits (K)' ,12 , '#164166' )
      g.set_y_max(200)
      g.set_y_label_steps(4)
      g.line_dot( 2, 4, '#818D9D', 'Hits', 10 )


      g.set_data(data_response_bytes)
      g.set_y_right_max(200)
      g.set_y_label_steps(10)
      g.line_hollow( 2, 4, '#164166', 'Bytes', 10 )
      g.attach_to_y_right_axis(2)
      g.set_y_legend_right( 'Bytes (GB)' ,12 , '#164166' )
      
      
      #  g.set_y_right_max(1700)
      #  g.set_x_axis_color('#818D9D', '#F0F0F0' )
      #  g.set_y_axis_color( '#818D9D', '#ADB5C7' )
      #  g.y_right_axis_color('#164166' )
      #  g.set_x_legend( 'My IRC Server', 12, '#164166' )
      #  g.set_y_legend( 'Max Users', 12, '#164166' )
      

      render :text => g.render
    end
private
  def filter_interval
    @interval = parse_interval(params[:interval]).downcase
  end

  def parse_interval(interval)
    return '3 MONTHS' if not params.has_key?(:interval)
    
    interval = params[:interval]
    return '3 MONTHS' if interval.blank?
    
    n = parse_interval_expression(interval, 'days', 1, 90)
    return n if n

    n = parse_interval_expression(interval, 'weeks', 1, 52)
    return n if n

    n = parse_interval_expression(interval, 'years', 1, 1)
    return n if n
    
    return '3 MONTHS'
  end
  
  def parse_interval_expression(interval, unit, min, max)
    r = Regexp.new("(\d+) #{unit}")
    
    if r.match(interval)
      n = $1.to_i
      return nil if n < min or n > max
      return n
    end
  end
  
end
