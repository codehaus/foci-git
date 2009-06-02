################################################################################
#  Copyright 2007 Codehaus Foundation                                          #
#                                                                              #
#  Licensed under the Apache License, Version 2.0 (the "License");             #
#  you may not use this file except in compliance with the License.            #
#  You may obtain a copy of the License at                                     #
#                                                                              #
#     http://www.apache.org/licenses/LICENSE-2.0                               #
#                                                                              #
#  Unless required by applicable law or agreed to in writing, software         #
#  distributed under the License is distributed on an "AS IS" BASIS,           #
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    #
#  See the License for the specific language governing permissions and         #
#  limitations under the License.                                              #
################################################################################

require 'parsedate'
require 'find'

class Foci::LoadData
  attr_accessor :source
  attr_accessor :logger
  attr_reader :incremental

  def initialize(options)
    @incremental = options[:incremental]
    @host = options[:host]
  end

  def load(file)
    begin
      puts "#{@host}: Loading #{file}"
      if FileTest.directory?(file)
        load_dir(file)
      else
        load_file(file)
      end
    ensure
      if @raw_conn
        puts "Closing raw conn"
        @raw_conn.close
      end
    end
  end
  
  def load_dir(dir)
    puts "Loading all files under #{dir}"
    Find.find(dir) { |file|
      while (la = loadavg) > 8.0
        puts "Waiting for load average to fall below 8; currently #{la}"
        sleep(30)
      end
      
      if FileTest.file?(file)
        load_file(file)
      end
    }
  end
  
  def loadavg
    up = `uptime`.strip
    if up =~ /^.* load averages?: ([\d\.]+),.*$/
      return $1.to_f
    else
      return 99.0
    end
  end
    
  def load_file(file)
    @logger = Logger.new(STDERR)
    @logger.level = Logger::INFO
    
    file = File.expand_path(file)
    base = File.expand_path(File.dirname(__FILE__) + '/../../')
    
    @logger.debug "Base: #{base}"
    @logger.debug "File: #{file}"
    
    url = "file:///#{file}"
    puts "URL: #{url}"
    io = nil
    
    handlers = []
    handlers << Foci::Handlers::BzipHandler.new
    handlers << Foci::Handlers::GzipHandler.new
    handlers << Foci::Handlers::RawHandler.new
    
    io = ""
    handler = nil
    for tmp_handler in handlers
      if tmp_handler.will_handle?(file)
        handler = tmp_handler
        break
      end
    end
    
    name = handler.name(file)
    
    @logger.info "Name: #{name}"
    @logger.info("Found handler #{tmp_handler.class.name} for #{file}")
    
    @logger.debug "Loading..."
  
    @source = find_source(name)
    source_size = File.size(file)
    @skip = 0
    if @source
      if @source.loaded
        if @incremental and source_size != @source.size
          @logger.info("#{source} already loaded; however incremental mode " +
                       "is enabled and the size is different")
          @skip = @source.line_count
        else
          @logger.info("#{source} already loaded")
          return
        end
      else
        @logger.info("#{source} failed loading last time")
      end
    else
      @source = create_source(name, url)
    end
    
    begin
      @source.size = source_size
      @source.url = url
      io = handler.open(file)
      @logger.debug "Command: #{io}"
      load_from_io_string(io)
      @source.loaded = true
      @source.save!
    rescue Exception => e
      puts e.inspect
      @source.loaded = false
      @source.save!
      raise
    end
    
    @logger.info "Completed: #{@source}"
  end
  
  def find_source(name)
    return Source.find_by_host_and_name(@host, name)
  end
  
  def create_source(name, url = nil)
    @source = Source.new
    @source.host = @host
    @source.name = name
    @source.loaded = false
    @source.url = url || 'about://none'
    @source.save!
    @source  
  end
  
  def load_from_io_string(io_string)
    @parser = Foci::Parser.new
    
    sqlexec("TRUNCATE TABLE RAW_LINES")
    
    @copy_lines = []
    #Profiler__::start_profile
    sqlexec("SET TEMP_BUFFERS=10240")
    start_copy()
    
    index = 0
    all_start = Time.now.to_f
    batch_start = Time.now.to_f
    batch_size = 1000
    @rejected_lines = []
    
    IO.popen(io_string) { |io|
      buffer = []
      begin
        while true
          batch_start = Time.now.to_f
          1.upto(batch_size) { |i|
            line = io.readline
            index = index + 1
            
            # If we need to skip some lines...
            if @skip > 0
              @skip = @skip - 1
              next
            end

            if line.length > 4000
               # It'll be spam... ignore
               puts "Spam access length: #{line.length}"
               next
            end
            line.gsub!( '\x', 'x' ) #Stupid!
            buffer << line
          }

          load_lines(buffer, index)
          delta = Time.now.to_f - batch_start
          @logger.info "#{index} (#{batch_size}) rows processed in " +
                       "#{sprintf('%2.2f', delta)} seconds (" +
                       "#{sprintf('%2.2f', batch_size / delta)} lines/second)" 
          buffer.clear
        end
      rescue EOFError => e
        # All good - EOF is expected at some point
      end
      
      load_lines(buffer, index)
      delta = Time.now.to_f - batch_start
      @logger.info "#{index} (#{batch_size}) rows processed in " +
                   "#{sprintf('%2.2f', delta)} seconds (" +
                   "#{sprintf('%2.2f', batch_size / delta)} lines/second)" 
      buffer.clear
      
      delta = Time.now.to_f - all_start
      @logger.info "OVERALL: #{index - @skip}) rows processed in " +
                   "#{sprintf('%2.2f', delta)} seconds (" +
                   "#{sprintf('%2.2f', (index - @skip) / delta)} lines/second)" 
    }
    end_copy
    
    sqlexec("VACUUM ANALYZE RAW_LINES") # Quick; and reclaims deleted space
    
    if not @rejected_lines.empty?
      puts "Storing #{@rejected_lines.length} rejected line(s)"
      @rejected_lines.each { |rl|
        begin
          RejectedLine.new(rl).save!
        rescue Exception => e
          puts "Rejected Line rejected again... oh well: #{e}"
        end
      }
      @rejected_lines.clear
    end
    
    puts "Done."
    
    if index == @skip
      # This typically occurs when the file has been compressed and
      # we're rechecking it
      puts "No lines processed, skipping processing"
      return
    end

    # LOTS OF WORK_MEM == FASTER QUERIES
    sqlexec("SET WORK_MEM=65536")
    #sqlexec("SET LOCAL synchronous_commit TO OFF")
    RawLine.exec_normalize_period
    RawLine.exec_link_source_period
    RawLine.exec_normalize_vhost
    RawLine.exec_normalize_path
    #sqlexec("SET LOCAL synchronous_commit TO ON")
    #RawLine.exec_normalize_subnet
    
    # Now for aggregation
    SubnetTotal.exec_aggregate_subnet_total
    PathTotal.exec_aggregate_path_total
    
    @source.line_count = index
    @source.save!
  end
  
  def load_lines(buffer, start)
    index = -1

    for line in buffer
      index = index + 1
      begin
        load_line(line, start + index)
      rescue Exception => e
        puts "Failure parsing (#{e}): #{line}"
        # Can't do AR directly here because of the COPY in progress
        rl = {}
        rl[:source_id] = @source.id
        rl[:line_number] = start + index
        rl[:line_text] = line
        @rejected_lines << rl
      end
    end
  end
  
  def load_line(line, index)
    #puts "The line: #{line}"
    split_line(line, index)
  end
  
  def split_line(line, index)
    line.gsub!('\"', "'")
    fields = @parser.parse(line)
    
    if fields[:bytecount] == '-'
      fields[:bytecount] = 0 
    else
      fields[:bytecount] = fields[:bytecount].to_i
    end
    
    path ||= fields[:request]
    path ||= ''
    
    # Remove the GET / POST and the HTTP/1.1 junk
    path_pieces = path.split(' ')
    if path_pieces.length < 2 || path_pieces.length > 3
      raise "Bad line: wrong number of spaces (#{path_pieces.length})!"
    end
    
    method = path_pieces[0]
    path = path_pieces[1]
    #http = path_pieces[2] # We don't use it - and it's not always provided
    
    if method.length > 10
      raise "Bad line: method was more than 10 characters - bad line presumably"
    end
    
    
    # Strip off trailer
    path = path.split('?')
    if path
      path = path.first
      # Cut it down to something sensible; this help avoid duplicate path
      # entries for the same file
      path = Path.normalize_path(path)
      # Limit to reasonable length
      path = path[0..254]
      path.strip!
    else
      path = ''
    end
    
    
    
    #Needs to match copy_line field ordering
    field_data = [
      @source.id,
      fields[:ip],
      fields[:auth],
      fields[:username],
      fields[:datetime],
      fields[:request],
      method,
      path,
      fields[:status],
      fields[:bytecount],
      fields[:domain],
      fields[:duration]
    ]
    
    copy_line(field_data)
    
  end
  
  def start_copy
    raise "copy already started" if @raw_conn
    # CUSTOMSQL create dynamic import sql code using 'COPY FROM' sql statement
    # Needs to match split_line
    field_names = ['source_id', 'ip', 'auth', 'username', 'datetime', 'request',
                   'method', 'path', 'status', 'bytecount', 'host', 'duration']
    import_sql = ''
    import_sql += "COPY RAW_LINES "
    import_sql += "(#{field_names.join(', ')}) "
    import_sql += "FROM STDIN; "

    # CUSTOMSQL we obtain a raw PGconn SQL connection to the database so we
    # can ship data directly to STDIN on the Postgres SQL connection
    @raw_conn = ActiveRecord::Base.connection.raw_connection
    # execute the import SQL, which will leave the connection open so we can
    # ship raw records directly to STDIN on the server, via PGconn.putline
    # command (below)
    
    dump_status('pre copy')
    @raw_conn.exec(import_sql)
    dump_status('post copy start')
    @line_count = 0
  end
  
  def copy_line(field_data)
    @line_count = @line_count + 1
    @raw_conn.put_copy_data(field_data.join("\t") + "\n")
  end
  
  def end_copy
    # Tell the driver we are done sending data
    @raw_conn.put_copy_end 
    puts "Lines transferred: #{@line_count}"
    if @raw_conn.status != 0
      raise CoreERR_SQLError, "server reports error code of " +
            "#{@raw_conn.status}. Status code should have been 0"
    end
    @raw_conn = nil
  end
  
  def dump_status(context = '')
    return
    if @raw_conn
      puts "Status(#{context}): #{@raw_conn.status}"
    else
      puts "Status(#{context}): @raw_conn not connected"
    end
  end
  
  def sqlexec(sql, title = nil)
    title ||= sql
    puts "Running #{title}"
    start = Time.new
    ActiveRecord::Base.connection.execute(sql)
    finish = Time.new
    
    puts "Complete (#{finish - start}s)"
  end

end
