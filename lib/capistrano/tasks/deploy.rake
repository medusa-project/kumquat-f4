namespace :deploy do

  desc 'Installs the UIUC website theme'
  task :install_uiuc_theme do
    on 'medusa@medusatest.library.illinois.edu' do
      execute "git clone git://github.com/medusa-project/kumquat-uiuc-theme.git "\
      "#{File.join(current_path, 'local', 'themes', 'uiuc')}"
      execute :rake, 'kumquat:set_default_theme[UIUC]'
    end
  end

  after 'deploy', 'deploy:install_uiuc_theme'

end
