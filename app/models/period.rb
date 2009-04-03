class Period < ActiveRecord::Base
  has_many :traffic_totals
  has_many :download_totals
  
  def to_s
    "Period[id=#{id}, name=#{name}, start=#{start}, duration=#{duration}]"
  end
  
  
  def self.find_recent(vhost)
    periods = Period.find_by_sql(<<-EOF
SELECT P.* FROM PERIODS P WHERE 
      START > NOW() - INTERVAL '1 MONTH'
  AND EXISTS (SELECT * FROM PATH_TOTALS PT WHERE VHOST_ID = #{vhost.id} AND P.ID = PT.PERIOD_ID)
  ORDER BY START DESC
EOF
    )
    
    if periods.empty?
      periods = Period.find_by_sql(<<-EOF
SELECT P.* FROM PERIODS P WHERE 
  EXISTS (SELECT * FROM PATH_TOTALS PT WHERE VHOST_ID = #{vhost.id} AND P.ID = PT.PERIOD_ID) 
  ORDER BY START DESC
  LIMIT 10
EOF
      )
    end
    
    return periods
  end
end
