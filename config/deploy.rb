require "rvm/capistrano"
require "bundler/capistrano"
require "bundler"

set :rvm_ruby_string, 'ruby-2.0.0-p247'   # use the same ruby as used locally for deployment
set :rvm_autolibs_flag, "read-only"       # more info: rvm help autolibs
set :rvm_type, :system                    # take that RVM

set :application, "railsapp"
set :repository,  "https://github.com/huit/railsapp-myapp.git"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/srv/www/rails/railsapp"

set :bundle_flags, "--deployment --binstubs"

set :ssh_options, {:forward_agent => true, :keys => [File.join(ENV["HOME"], ".vagrant.d", "insecure_private_key")]}

role :web, "10.0.2.15"                          # Your HTTP server, Apache/etc
role :app, "10.0.2.15"                          # This may be the same as your `Web` server
role :db,  "10.0.2.15", :primary => true # This is where Rails migrations will run

before 'deploy:setup', 'rvm:create_gemset' # only create gemset
before 'bundle:install' do try_sudo('yum -y install sqlite-devel') end

# if you want to clean up old releases on each deploy uncomment this:
after 'deploy:restart', 'deploy:cleanup'
after 'deploy:cleanup' do try_sudo('chown -R rails:rails /srv/www/rails') end

default_run_options[:pty] = true

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
