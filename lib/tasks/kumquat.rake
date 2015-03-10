namespace :kumquat do

  desc 'Import content from CONTENTdm'
  task :cdm_import, [:source_path] => :environment do |task, args|
    importer = Contentdm::Importer.new(args[:source_path])
    importer.import
  end

  desc 'Update indexing'
  task :update_indexing => :environment do |task, args|
    puts 'Creating Fedora indexing transform'
    Fedora::Repository.new.apply_indexing_transform
  end

end
