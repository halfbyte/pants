require 'appsignal/capistrano' rescue LoadError

require 'dotenv'
Dotenv.load

# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'pants'
set :stages, ["production"]
set :repo_url, 'git@github.com:halfbyte/pants.git'
set :branch, 'uberspace'
set :deploy_via, :remote_cache

set :home, '/home/halfbyte'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/virtual/halfbyte/rails/pants'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{.env.production}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

set :passenger_port, rand(61000-32768+1)+32768

# set :chruby_ruby, '2.1'

namespace :daemontools do
  task :setup_daemon do
    daemon_script = <<-EOF
#!/bin/bash
export HOME=#{fetch :home}
source $HOME/.bash_profile
cd #{fetch :deploy_to}/current
exec bundle exec passenger start -p #{fetch :passenger_port} -e production 2>&1
EOF

    log_script = <<-EOF
#!/bin/sh
exec multilog t ./main
EOF

    run "mkdir -p #{fetch :home}/etc/run-rails-#{fetch :application}"
    run "mkdir -p #{fetch :home}/etc/run-rails-#{fetch :application}/log"
    put daemon_script, "#{fetch :home}/etc/run-rails-#{fetch :application}/run"
    put log_script, "#{fetch :home}/etc/run-rails-#{fetch :application}/log/run"
    run "chmod +x #{fetch :home}/etc/run-rails-#{fetch :application}/run"
    run "chmod +x #{fetch :home}/etc/run-rails-#{fetch :application}/log/run"
    run "ln -nfs #{fetch :home}/etc/run-rails-#{fetch :application} #{fetch :home}/service/rails-#{fetch :application}"

  end
end


 namespace :apache do
    task :setup_reverse_proxy do
      htaccess = <<-EOF
RewriteEngine On
RewriteRule ^(.*)$ http://localhost:#{fetch :passenger_port}/$1 [P]
EOF
      path = fetch(:domain) ? "/var/www/virtual/#{fetch :user}/#{fetch :domain}" : "#{fetch :home}/html"
      run "mkdir -p #{path}"
      put htaccess, "#{path}/.htaccess"
      run "chmod +r #{path}/.htaccess"
      run "uberspace-add-domain -qwd #{fetch :domain} ; true" if fetch(:domain)
    end
  end



namespace :deploy do
  task :start do
    run "svc -u #{fetch :home}/service/rails-#{fetch :application}"
  end
  task :stop do
    run "svc -d #{fetch :home}/service/rails-#{fetch :application}"
  end
  task :restart do
    run "svc -du #{fetch :home}/service/rails-#{fetch :application}"
  end
  
  after :publishing, :restart

  # after :restart, :clear_cache do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     # Here we can do anything such as:
  #     # within release_path do
  #     #   execute :rake, 'cache:clear'
  #     # end
  #   end
  # end
end
