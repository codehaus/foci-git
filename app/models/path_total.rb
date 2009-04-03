class PathTotal < ActiveRecord::Base
  belongs_to :vhost
  belongs_to :period
  belongs_to :path
  
  def self.exec_aggregate_path_total
    log("Aggregating path totals")
    StoredProc.exec('sp_aggregate_path_total()')
  end
  
  def self.top_paths(period)
    sql = <<-EOF
     SELECT 
        VHOST_ID,
        PATH_ID,
        P.PATH AS PATH_PATH,
        SUM(response_count) AS response_count, 
        SUM(response_bytes) AS response_bytes,
        SUM(response_bytes) / SUM(response_count) AS average_response_bytes,
        SUM(response_time) / SUM(response_count) AS average_response_time
      FROM PATH_TOTALS PT, PATHS P
      WHERE PERIOD_ID = #{period.id}
      AND PT.PATH_ID = P.ID
      AND P.PATH <> ''
      GROUP BY VHOST_ID, PATH_ID, P.PATH
      ORDER BY SUM(response_bytes) desc
      LIMIT 10
EOF
    puts sql
    return PathTotal.find_by_sql(sql)
    
  end
  
   def self.top_vhosts(period)
    sql = <<-EOF
     SELECT 
        VHOST_ID,
        SUM(response_count) AS response_count, 
        SUM(response_bytes) AS response_bytes,
        SUM(response_bytes) / SUM(response_count) AS average_response_bytes,
        SUM(response_time) / SUM(response_count) AS average_response_time
      FROM PATH_TOTALS PT
      WHERE PERIOD_ID = #{period.id}
      GROUP BY VHOST_ID
      ORDER BY SUM(response_bytes) desc
      LIMIT 10
EOF
    puts sql
    return PathTotal.find_by_sql(sql)

  end
  
  def self.totals_for_period(period)
    return self.totals_for_vhost_period(nil, period)
  end
  
  def self.totals_for_vhost_period(vhost, period)
    conditions = []
    selectors = []
    if vhost
      selectors << 'vhost_id'
      conditions << "VHOST_ID = #{vhost.id}"
    end
    
    if period
      selectors << 'period_id'
      conditions << "PERIOD_ID = #{period.id}"
    end
    
    sql = <<-EOF
    SELECT 
      #{selectors.empty? ? '' : selectors.join(', ') + ', '}
      SUM(response_count) AS response_count, 
      SUM(response_bytes) AS response_bytes,
      SUM(response_bytes) / SUM(response_count) AS average_response_bytes,
      SUM(response_time) / SUM(response_count) AS average_response_time
    FROM PATH_TOTALS PT
    WHERE
          #{conditions.join(' AND ')}
    #{selectors.empty? ? '' : "GROUP BY #{selectors.join(', ')}"}
EOF
    puts sql
    return find_by_sql(sql)
  end
  
  def self.update_hot_domains
  end
private
  def self.log(msg)
    puts msg
  end
    
  
end
