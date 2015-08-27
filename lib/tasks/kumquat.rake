namespace :kumquat do

  desc 'Import content from CONTENTdm'
  task :import_cdm, [:source_path] => :environment do |task, args|
    delegate = Contentdm::ImportDelegate.new(args[:source_path])
    Import::Importer.new(delegate).import
    Solr::Solr.client.commit
  end

  desc 'Import using an import delegate'
  task :import, [:delegate] => :environment do |task, args|
    delegate = args[:delegate].constantize.new
    Import::Importer.new(delegate).import
    Solr::Solr.client.commit
  end

  desc 'Import the demo collections'
  task :import_demo => :environment do
    delegate = SampleData::ImportDelegate.new
    Import::Importer.new(delegate).import
    Solr::Solr.client.commit
  end

  desc 'Set the default theme'
  task :set_default_theme, [:theme] => :environment do |task, args|
    theme = Theme.find_by_name(args[:theme])
    if theme
      theme.default = true
      theme.save!
    else
      puts "#{args[:theme]} not found."
    end
  end

end
