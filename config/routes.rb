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
  
  map.root :controller => 'home', :conditions => { :method => :get }
  map.resources :charts, :only => :index,
                         :collection => { :sources_per_day => :get,
                                          :sources_per_day_data => :get,
                                          :historical_load => :get,
                                          :historical_load_data => :get }

  map.resources :core, :only => :index, :controller => 'core'
  map.resource :prefix, :only => :none, :controller => 'prefix',
                        :member => { :simple => :get, :simple_data => :get,
                                     :ajax_update => [:get, :post],
                                     :progress => :get, :data => :get }

  map.resources :search, :only => :index, :controller => 'search',
                         :collection => { :index => [:get, :post] }
  map.resources :sources, :only => :none, :collection => { :list => :get } 
  map.resources :status, :only => :index, :controller => 'status',
                         :collection => { :sources_data => :get,
                                          :totals_data => :get,
                                          :domains_data => :get,
                                          :paths_data => :get }

  map.resources :vhosts, :only => :index,
                         :requirements => { :vhost => /[a-z0-9\-\.]*/ }
end
