class Foci::Handlers::Handler
  #I know ruby doesn't require an interfacesque definition - but it provides the hook points
  def will_handle?(url)
    raise Exception.new("implement #{self.class.name}.will_handle?")
  end
  
  #Should return an IO object
  def open(url)
    raise Exception.new("implement #{self.class.name}.open")
  end
  
  def name(url)
    raise Exception.new("implement #{self.class.name}.name")
  end
    
end