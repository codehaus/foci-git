class SubnetTotalCache < ElementCache
  
  def preload
  end
  
  def mark_changed(subnet_total)
    internal_mark_changed([subnet_total.vhost_id, subnet_total.period_id, subnet_total.subnet_id])
  end
  
  def find_by_vhost_id_and_period_id_and_subnet_id(vhost_id, period_id, subnet_id)
    key = [ vhost_id, period_id, subnet_id ]
    subnet_total = load_cache(key)
    
    return subnet_total if subnet_total
    
    subnet_total = SubnetTotal.find_by_vhost_id_and_period_id_and_subnet_id(vhost_id, period_id, subnet_id)
    if not subnet_total
      subnet_total = SubnetTotal.new
      subnet_total.vhost_id = vhost_id
      subnet_total.period_id = period_id
      subnet_total.subnet_id = subnet_id
      subnet_total.count = 0
      subnet_total.bytes_stddev = 0
      subnet_total.bytes_total = 0
      subnet_total.save
      #puts "Created new #{subnet_total}"
    end
    save_cache(key, subnet_total)
    return subnet_total
  end
  
  def transaction
    SubnetTotal.transaction do
      yield
    end
  end
  
  
end