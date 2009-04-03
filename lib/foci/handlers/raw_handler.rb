#The handler of last resort
class Foci::Handlers::RawHandler < Foci::Handlers::Handler
  def will_handle?(url)
    return true
  end
  
  def open(url)
    return "cat #{url}"
  end
  
  def name(url)
    File.basename(url)
  end
  
end
