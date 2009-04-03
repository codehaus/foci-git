class PeriodCache < ElementCache
    
  def preload
    Period.find(:all).each { |period|
      save_cache(resolve(period.start).to_s, period)
    }
  end

  
  def resolve(datetime)
    #Remove the time and continue on
    #20/Oct/2006:00:00:00 -0500
    Time.utc( datetime.year, datetime.month, datetime.day )
  end

  def find_by_datetime(datetime)
    datetime_start = resolve(datetime)
    period = load_cache(datetime_start.to_s)
    
    return period if period
    
    period = Period.find_by_start(datetime_start)
    if not period
      #puts "Creating new Period #{period}"
      duration = 86400
      period = Period.new
      period.name=datetime_start
      period.start = datetime_start
      period.finish = datetime_start + duration - 1
      period.duration = duration
      period.save!
    end
    
    save_cache(datetime_start.to_s, period)
    return period
  end

end