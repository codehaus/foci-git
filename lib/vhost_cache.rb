class VhostCache < ElementCache
  
  def preload
    Vhost.find(:all).each { |vhost|
      save_cache(vhost.host, vhost)
    }
  end

  def find_by_name(name)
    raise ArgumentError.new("name not set") if not name
    
    vhost = load_cache(name)
    
    return vhost if vhost
    
    vhost = Vhost.find_by_host(name)
    if vhost
      save_cache(vhost.host, vhost)
      return vhost
    end
    
    logger.debug "Creating new VHost #{name}"
    vhost = Vhost.new
    vhost.host = name
    vhost.aggregate_traffic_total = true
    
    #These hosts generally have a whole lot of crappy paths that are of no interest in download stats etc
    case vhost.dcs.first
      when 'archive', 'svn', 'scm', 'cvs', 'fisheye', 'stats', 'unity'
        vhost.aggregate_download_total = false
      else
        vhost.aggregate_download_total = true
    end
        
    vhost.save
    save_cache(name, vhost)
    return vhost
  end

end