namespace :kumquat do

  desc 'Import content from CONTENTdm'
  task :cdm_import, [:source_path] => :environment do |task, args|
    delegate = Contentdm::ImportDelegate.new(args[:source_path])
    Import::Importer.new(delegate).import
  end

  desc 'Import using an import delegate'
  task :import, [:delegate] => :environment do |task, args|
    delegate = args[:delegate].constantize.new
    Import::Importer.new(delegate).import
  end

  desc 'Import the sample collection'
  task :sample_import => :environment do
    delegate = SampleData::ImportDelegate.new
    Import::Importer.new(delegate).import
  end

  desc 'Set the default theme'
  task :set_default_theme, [:theme] => :environment do |task, args|
    theme = Theme.find_by_name(args[:theme])
    theme.default = true
    theme.save!
  end

  desc 'Update Fedora index transform'
  task :update_index_transform => :environment do
    Repository::Fedora.new.apply_indexing_transform
    puts "Fedora indexing transform "\
    "\"#{Repository::Fedora::INDEXING_TRANSFORM_NAME}\" updated"
  end

  desc 'Update Solr schema'
  task :update_solr_schema => :environment do
    Solr::Solr.new.update_schema
  end

end
