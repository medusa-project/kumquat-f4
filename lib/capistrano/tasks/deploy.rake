namespace :deploy do

  desc 'Installs the UIUC website theme'
  task :install_uiuc_theme do
    on primary(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          execute "rm -rf #{File.join('local', 'themes', 'uiuc')}"
          execute "git clone git://github.com/medusa-project/kumquat-uiuc-theme.git "\
          "#{File.join(current_path, 'local', 'themes', 'uiuc')}"
          execute :rake, 'kumquat:set_default_theme[UIUC]'
          execute :rake, 'assets:clobber'
          execute :rake, 'assets:precompile' # compile theme assets
        end
      end
    end
  end

  after 'deploy', 'deploy:install_uiuc_theme'

end
