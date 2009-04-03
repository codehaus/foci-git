################################################################################
#  Copyright 2007-2008 Codehaus Foundation
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
################################################################################

#Prototype class...
class Foci::LogParserFast
  def initialize(args)
    
  end
  
  def parse_line(line)
    fields = {}
    #91.65.216.53 - - [22/Mar/2008:09:32:59 -0500] "GET /favicon.ico HTTP/1.1" 404 266 "-" "Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.8.1.12) Gecko/20080201 Firefox/2.0.0.12" xfire.codehaus.org 0
    
    :combined_codehaus => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\" %v %d',
    pieces = line.split(' ')
    
    
    fields[:ip]       = pieces[0] 
    fields[:auth]     = pieces[1] 
    fields[:username] = pieces[2] 
    fields[:datetime] = pieces[3][1..-1] + ' ' + pieces[4][0..-2] 
    fields[:request]
    index = 1
    for piece in pieces
      
    
  end
  
  
end