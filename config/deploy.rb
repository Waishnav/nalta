# config valid for current version and patch releases of Capistrano
lock "~> 3.19.1"

set :application, "nalta"
set :repo_url, "git@example.com:waishnav/nalta.git"

set :deploy_to, "/home/deploy/#{fetch :application}"

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'

# Only keep the last 5 releases to save disk space
set :keep_releases, 5
