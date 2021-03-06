set :application, "nerdtanke"
set :repository,  "git@github.com:nerdtanke/nerdtanke.git"
set :deploy_to, "/opt/www/#{application}"
set :user, "deploy"

set :scm, :git
set :deploy_via, :remote_cache
set :branch, "master"

set :keep_releases, 2

ssh_options[:forward_agent] = true

server "triskweline.de", :app, :web, :db, :primary => true

namespace :deploy do
  task :restart do
    # no need to restart the app
  end
end

