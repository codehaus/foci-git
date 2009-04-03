################################################################################
#  Copyright 2006-2009 Codehaus Foundation
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
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  #All controllers have this configured, it is up to them to use it though
  before_filter :filter_host
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '743560dc964be8faa6b1fe4c41fbce33'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password
  
protected
  # Finds a vhost for the current site, based on the request header
  def filter_host
    @core_host = nil
    @core_vhost = nil
    
    @core_host = get_host_without_port
    if @core_host
      @core_vhost = Vhost.find_best_host(@core_host)
    else
      @core_vhost = nil
    end
  end
  
  def get_host_without_port
    host = get_host
    return nil if not host
    return nil if host.blank?
    
    return host.split(':')[0]
  end

  #You intentionally can't override a host from the VHost (which means that Apache has applied authentication)
  #using the parameter (i.e. host header = stats.clown.codehaus.org (your project, authorized), host param = secret.codehaus.org)
  def get_host
    return request.headers['HTTP_HOST'] if request.headers.has_key?('HTTP_HOST')
      
    return params[:host] if params.has_key?(:host)
  end
end