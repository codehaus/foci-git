module RenderHelper
  def render_bytes(bytes)
    bytes = bytes.to_f if bytes.class.name == 'String'
    sizes = [ "B", "kB", "MB", "GB", "TB" ]
    
    index = 0
    
    while bytes > 1.2 * 1024
      bytes = bytes / 1024.0
      index = index + 1
    end
    
    #if index == 0
    #  return "#{bytes}B"
    #else
    sprintf("%2.1f%s", bytes, sizes[index])
    #end
  end
end
