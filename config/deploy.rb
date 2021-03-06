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

set :application, "foci"




role :app, "codehaus03.managed.contegix.com"
role :web, "codehaus03.managed.contegix.com"
role :db,  "codehaus03.managed.contegix.com", :primary => true

set :deploy_to, '/opt/foci'
set :use_sudo, false
set :user, 'ror-foci'

ssh_options[:user] = 'ror-foci'
ssh_options[:forward_agent] = true

# Repository options
set :scm, "git"
set :git_enable_submodules, 1
set :repository,  "git://git.rubyhaus.org/foci-git.git"
set :branch, "master"

# Deployment options
set :deploy_via, :remote_cache
set :use_sudo, false




# A Passenger based restart routine
namespace :deploy do
  task :restart, :roles => :web do
    #Restart
    run "touch #{current_path}/tmp/restart.txt"
  end
end

task :after_update_code, :roles => [ :app ] do
  run <<-CMD
    mkdir -p #{shared_path}/tmp/sessions &&
    rm -rf #{release_path}/tmp &&
    ln -nfs #{shared_path}/tmp #{release_path}/tmp
  CMD
end

