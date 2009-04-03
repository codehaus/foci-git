class TrafficTotalCache < ElementCache
  def preload
  end
  
  def mark_changed(traffic_total)
    internal_mark_changed([traffic_total.vhost_id, traffic_total.period_id])
  end
  
  def find_by_vhost_id_and_period_id(vhost_id, period_id)
    key = [ vhost_id, period_id ]
    traffic_total = load_cache(key)
    
    return traffic_total if traffic_total
    
    traffic_total = TrafficTotal.find_by_vhost_id_and_period_id(vhost_id, period_id)
    if not traffic_total
      traffic_total = TrafficTotal.new
      traffic_total.vhost_id = vhost_id
      traffic_total.period_id = period_id
      traffic_total.count = 0
      traffic_total.bytes_stddev = 0
      traffic_total.bytes_total = 0
      traffic_total.bytes_average = 0
      traffic_total.save
      logger.debug "Created new #{traffic_total}"
    end
    save_cache(key, traffic_total)
    return traffic_total
  end
  
  def transaction
    TrafficTotal.transaction do
      yield
    end
  end
  
  
end