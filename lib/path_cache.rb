class PathCache < ElementCache
    
  def preload
    @preload = false #There's over 700k elements in a fully stocked database
    
    if @preload
      Path.find(:all).each { |path|
        save_cache(path.path, path)
      }
    end
  end

  def find_by_path(path_text)
    path = load_cache(path_text)
    
    return path if path
    path = Path.find_by_path(path_text) unless @preload
    if not path
      path = Path.new
      path.path = path_text
      path.save!
    end
    
    save_cache(path_text, path)
    return path
  end


  def transaction
    Path.transaction do
      yield
    end
  end

end