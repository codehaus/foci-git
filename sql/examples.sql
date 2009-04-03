select  
  to_char(pd.start, 'YYYYMM') AS Period,
  SUM(response_count) AS response_count,
  SUM(response_bytes) AS response_bytes,
  SUM(response_time) / SUM(response_count) AS average_response_time,
  SUM(response_bytes) / SUM(response_count) AS average_response_bytes, 
  p.path AS Path
from 
  path_totals pt, 
  paths p, 
  periods pd
where 
      vhost_id = (select id from vhosts where host = 'dist.codehaus.org') 
  and pt.path_id = p.id 
  and p.path like '/groovy/%'
  and pd.id = pt.period_id
  and pd.start > NOW() - INTERVAL '3 MONTHS'
group by 
  to_char(pd.start, 'YYYYMM'), 
  p.path
order by  
  to_char(pd.start, 'YYYYMM'), 
  sum(response_bytes) desc;

