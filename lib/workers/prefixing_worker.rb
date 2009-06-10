require File.dirname(__FILE__) + "/../../app/models/path_total"

class PrefixingWorker < BackgrounDRb::MetaWorker
  set_worker_name :prefixing_worker

  # Called when the worker is created.
  def create(args = nil)
    cache['status'] = 'Worker started, waiting for next query to see, if ' +
                      'queue has any jobs available.'
  end

  # Test method that doesn't stress the DB at all.
  def load_test_prefix_data
    cache['status'] = "Running a job, with job_key #{job_key}."
    cache['current_job_key'] = "#{job_key}"
    result = job_key + '_result'
    status = job_key + '_status'

    while (la = loadavg) > 8.0
      cache[status] = "Waiting for the load average to fall below 8. " +
                   "Currently #{la}."
      sleep(30)
    end

    logger.info 'starting process'

    cache[status] = 'Waiting to start the load.'
    sleep(15)
    cache[status] = 'Fetching the data from the DB.'
    sleep(10)
    cache[status] = 'Building the xml.'
    sleep(15)
    cache[result] = "This job was finished at #{Time.now.to_s}"
    cache[status] = 'Job finished.'
    persistent_job.finish!

    logger.info 'finished!'
    cache['status'] = "Job #{job_key} finished, taking a small break before " +
                      'querying for more jobs.'
  end
  
  # Loads the requested prefix data from the DB. If server load is high,
  # will wait for a better time to run.
  def load_prefix_data options={}
    cache['status'] = "Running a job, with job_key #{job_key}."
    cache['current_job_key'] = "#{job_key}"
    result = job_key + '_result'
    status = job_key + '_status'
    cache[status] = "Started job with job_key: #{job_key}."

    while (la = loadavg) > 8.0
      cache[status] = "Waiting for the load average to fall below 8. " +
                   "Currently #{la}."
      sleep(30)
    end

    sql = <<-EOF
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
      vhost_id = (select id from vhosts where host = '#{options[:vhost]}') 
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

    # Only call the DB, if there isn't a cached result.
    if cache[result].nil?
      cache[status] = 'Result not found in cache, querying the database. ' +
                      'Note: This might take a while.'
      results = PathTotal.find_by_sql([sql, *options[:sql_args]])
      cache[result] = results
    end

    cache[status] = 'Job finished.'
    persistent_job.finish!

    logger.info 'finished!'
    cache['status'] = "Job #{job_key} finished, taking a small break before " +
                      'querying for more jobs.'
  end

  private

  def loadavg
    up = `uptime`.strip
    if up =~ /^.* load averages?: ([\d\.]+),.*$/
      return $1.to_f
    else
      return 99.0
    end
  end
end

