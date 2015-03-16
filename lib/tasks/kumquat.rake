namespace :kumquat do

  desc 'Import content from CONTENTdm'
  task :cdm_import, [:source_path] => :environment do |task, args|
    Contentdm::Importer.new(args[:source_path]).import
  end

  desc 'Import the sample collection'
  task :sample_import => :environment do |task, args|
    SampleData::Importer.new.import
  end

  desc 'Update indexing'
  task :update_indexing => :environment do |task, args|
    Fedora::Repository.new.apply_indexing_transform
    puts "Fedora indexing transform "\
    "\"#{Fedora::Repository::INDEXING_TRANSFORM_NAME}\" updated"
  end

end
