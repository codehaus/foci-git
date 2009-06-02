class Foci::DateParser
  MONTH_VALUE = { 'JAN' => 1, 'FEB' => 2, 'MAR' => 3, 'APR' => 4, 'MAY' => 5,
                  'JUN' => 6, 'JUL' => 7, 'AUG' => 8, 'SEP' => 9, 'OCT' => 10,
                  'NOV' =>11, 'DEC' =>12 }
  
  def self.parse(datetime)
    # 20/Oct/2006:00:00:00 -0500
    #DateTime.strptime(datetime, "%d/%b/%Y:%H:%M:%S %z")
    
    day = datetime[0..1]
    month_name = datetime[3..5]
    month = MONTH_VALUE[month_name.upcase]
    year = datetime[7..10]
    
    hour = datetime[12..13]
    minute = datetime[15..16]
    second = datetime[18..19]
    
    timezone_text = datetime[21..25]
    timezone_dir = timezone_text[0..0] == '-' ? -1 : +1
    timezone_hour = timezone_text[1..2].to_i
    timezone_minute = timezone_text[3..4].to_i
    timezone_offset = timezone_dir * (timezone_hour * 3600 +
                                      timezone_minute * 60)
    
    #puts datetime
    #puts "#{day} #{month_name}(#{month}) #{year} #{hour} #{minute} #{second}
    #      #{timezone_text} (#{timezone_offset})"
    #DateTime.strptime(datetime, "%d/%b/%Y:%H:%M:%S %z")
    
    #time = Time.utc(second, minute, hour, day, month, year, 0, 0, false,
    #                timezone)
    #puts time.zone
    Time.utc(year, month, day, hour, minute, second, 0) - timezone_offset
  end
end
