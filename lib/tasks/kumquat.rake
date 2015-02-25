namespace :kumquat do

  desc 'Import content from CONTENTdm'
  task :cdm_import, [:source_path] => :environment do |task, args|
    importer = ContentdmImporter.new(args[:source_path])
    importer.import
  end

end
