class SubnetCache < ElementCache
    
  def preload
    @preload = true
    
    if @preload
      Subnet.find(:all).each { |subnet|
        save_cache(subnet.address, subnet)
      }
    end
  end

  def find_by_address(address)
    subnet = load_cache(address)
    
    return subnet if subnet
    subnet = Subnet.find_by_address(address) unless @preload
    if not subnet
      subnet = Subnet.new
      subnet.address = address
      subnet.save!
    end
    
    save_cache(subnet.address, subnet)
    return subnet
  end


  def transaction
    Subnet.transaction do
      yield
    end
  end

end