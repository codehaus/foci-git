class SubnetUtility
  def self.address_to_integer(address)
    octets = address.split('.')
    octets.collect! { |octet| 
      octet.to_i
    }    
    octets[0] << 12 + octets[1] << 8 + octets[2] << 4 + octets[3]
  end
  
  def self.integer_to_address(i)
    a = [ 
      (i >> 12) % (1 << 4),
      (i >> 8)  % (1 << 4),
      (i >> 4)  % (1 << 4),
      (i)       % (1 << 4)
    ]
    a.join('.')
  end

end