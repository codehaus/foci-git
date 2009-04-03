class Foci::Handlers::BzipHandler < Foci::Handlers::Handler
  def will_handle?(url)
    url[-4..-1] == '.bz2'
  end
  
  def open(url)
    return "bzcat #{url}"
  end

  def name(url)
    File.basename(url)[0..-5]
  end

end