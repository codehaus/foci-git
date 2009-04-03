class Foci::Handlers::GzipHandler < Foci::Handlers::Handler
  def will_handle?(url)
    url[-3..-1] == '.gz'
  end
  
  def open(url)
    #This silliness is to account for OSX which doesn't have a useful zcat by default (expects certain filename extensions)
    return "cat #{url} | zcat"
  end
  
  def name(url)
    File.basename(url)[0..-4]
  end
  
  
end