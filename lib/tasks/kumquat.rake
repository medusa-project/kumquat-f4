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
    SampleData::Importer.new.import
  end

  desc 'Update index transform'
  task :update_index_transform => :environment do
    Fedora::Repository.new.apply_indexing_transform
    puts "Fedora indexing transform "\
    "\"#{Fedora::Repository::INDEXING_TRANSFORM_NAME}\" updated"
  end

end
