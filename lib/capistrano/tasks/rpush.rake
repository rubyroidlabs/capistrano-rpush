git_plugin = self

namespace :load do
  task :defaults do
    execute_keys = %w[rpush]
    # Rbenv, Chruby, and RVM integration
    set :rbenv_map_bins, fetch(:rbenv_map_bins).to_a.concat(execute_keys)
    set :rvm_map_bins, fetch(:rvm_map_bins).to_a.concat(execute_keys)
    set :chruby_map_bins, fetch(:chruby_map_bins).to_a.concat(execute_keys)
    # Bundler integration
    set :bundle_bins, fetch(:bundle_bins).to_a.concat(execute_keys)
  end
end

namespace :rpush do
  desc 'Check if config file exists'
  task :check do
    on roles (fetch(:rpush_role)) do |role|
      unless  test "[ -f #{fetch(:rpush_conf)} ]"
        warn 'rpush.rb NOT FOUND!'
        info 'Configure rpush for your project before attempting a deployment.'
      end
    end
  end

  desc 'Restart rpush'
  task :restart do
    on roles (fetch(:rpush_role)) do |role|
      git_plugin.rpush_switch_user(role) do
        if test "[ -f #{fetch(:rpush_pid)} ]"
          invoke 'rpush:stop'
        end
        invoke 'rpush:start'
      end
    end
  end

  desc 'Start rpush'
  task :start do
    on roles (fetch(:rpush_role)) do |role|
      git_plugin.rpush_switch_user(role) do
        if test "[ -f #{fetch(:rpush_conf)} ]"
          info "using conf file #{fetch(:rpush_conf)}"
        else
          invoke 'rpush:check'
        end
        within current_path do
          with rack_env: fetch(:rpush_env) do
            execute :rpush, "start -p #{fetch(:rpush_pid)} -c #{fetch(:rpush_conf)} -e #{fetch(:rpush_env)}"
          end
        end
      end
    end
  end

  desc 'Status rpush'
  task :status do
    on roles (fetch(:rpush_role)) do |role|
      git_plugin.rpush_switch_user(role) do
        if test "[ -f #{fetch(:rpush_conf)} ]"
          within current_path do
            with rack_env: fetch(:rpush_env) do
              execute :rpush, "status -c #{fetch(:rpush_conf)} -e #{fetch(:rpush_env)}"
            end
          end
        end
      end
    end
  end

  desc 'Stop rpush'
  task :stop do
    on roles (fetch(:rpush_role)) do |role|
      git_plugin.rpush_switch_user(role) do
        if test "[ -f #{fetch(:rpush_pid)} ]"
          within current_path do
            with rack_env: fetch(:rpush_env) do
              execute :rpush, "stop -p #{fetch(:rpush_pid)} -c #{fetch(:rpush_conf)} -e #{fetch(:rpush_env)}"
            end
          end
        end
      end
    end
  end
end
