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

ActionController::Routing::Routes.draw do |map|
  
  map.connect '/',
    :controller => 'home'

  map.connect '/search',
   :controller => 'search'
  
  map.connect '/vhosts/:vhost',
   :controller => 'vhosts',
   :action => 'index',
   :requirements => { :vhost => /[a-z0-9\-\.]*/ }

  map.connect '/vhosts/:vhost/:action',
    :controller => 'vhosts',
    :requirements => { :vhost => /[a-z0-9\-\.]*/ }
    

  map.connect '/sources/:action',
    :controller => 'sources'

  map.connect '/status/:action', 
    :controller => 'status'
    
  map.connect '/charts/:action', 
    :controller => 'charts'
    
  map.connect '/prefix/:action', 
    :controller => 'prefix'

end
