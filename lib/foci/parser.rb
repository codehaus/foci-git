class Foci::LogItem
  def initialize(values)
    @values = values
  end
  
  def method_missing(name)
    the_field_index = Foci::LogItem.field_index(name)
    
    if the_field_index == -1 
      raise Exception.new("unknown field #{name}")
    end
    
    return @values[the_field_index]
  end
  
  def self.field_index(field_name)
    case field_name
      when 'ip'
        return 1
      else
        return -1
    end
  end

end

class Foci::Parser
  def initialize(vhost = nil, response_time = 0)
    @vhost = vhost
    @response_time = response_time
    @parser = Foci::LogParser.new()
  end
  
  def parse(line)
    values = []
    
    other_item = @parser.parse_line(line)
    ##if regexp_combined.matches(line) 
    #  puts "hey it matched!"
    #end
    
    @item = Foci::LogItem.new(values)
    return other_item
  end

end