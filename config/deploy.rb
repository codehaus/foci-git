set :application, "foci"
set :repository,  "https://svn.rubyhaus.org/foci/trunk/foci"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "codehaus03.managed.contegix.com"
role :web, "codehaus03.managed.contegix.com"
role :db,  "codehaus03.managed.contegix.com", :primary => true


set :deploy_to, '/opt/foci'
set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"
set :mongrel_user, 'ror-foci'
set :mongrel_group, 'ror-foci'
set :use_sudo, false
set :user, 'ror-foci'

ssh_options[:user] = 'ror-foci'