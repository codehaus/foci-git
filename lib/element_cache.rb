class ElementCache
  attr_writer :logger
  attr_reader :logger
  
  def initialize
    @elements = {}
    @logger = nil
    @last_commit = Time.now.to_i
    preload()
  end
  
  
  def save_cache(key, element)
   @elements[key] = [ element, false ]
  end
  
  def load_cache(key)
   return nil unless key
   
   if @elements.has_key?(key)
     value = @elements[key][0]
     #puts "Cache(#{self.class.name}) hit: #{key.inspect} (#{value.class.name})"
     return value
   else
     #puts "Cache(#{self.class.name})  miss: #{key.inspect}"
     return nil
   end
 end
 
 #default implementation
 def transaction
   yield
 end
 
 def internal_mark_changed(key)
   @elements[key][1] = true
 end
 
 def length()
   @elements.length()
 end
 
 def commit(commit_wait = 0)
   if Time.now.to_i - @last_commit > commit_wait
     puts "Committing #{self.class.name} cache..."
     count = 0
     transaction do
       @elements.each_pair { | key, value |
         if (value[1])
           value[0].save!   
           value[1] = false
           count = count + 1
         end
       }
     end
     @last_commit = Time.now.to_i
     puts "Complete (#{count}/#{@elements.length} items committed)"
   end
 end
 
 def rollback()
   @elements.each_pair { | key, value |
     value[1] = false
   }
 end
 
end