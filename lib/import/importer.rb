module Import

  class Importer

    ##
    # @param import_delegate [ImportDelegate]
    #
    def initialize(import_delegate)
      @import_delegate = import_delegate
      @import_id_uri_map = {} # map of import IDs => repository URIs
      @collections = {} # map of collection keys => collections
    end

    ##
    # @param options [Hash] with available keys: `:commit` [Boolean],
    # `:transactional` [Boolean]
    #
    def import(options = {})
      if options[:transactional]
        ActiveMedusa::Base.transaction do |tx_url|
          do_import(tx_url, options[:commit])
        end
      else
        do_import
      end
      solr_url = Kumquat::Application.kumquat_config[:solr_url].chomp('/')
      solr_collection = Kumquat::Application.kumquat_config[:solr_collection]
      puts "Import complete. Remember to commit the Solr index once it has "\
      "ingested everything, e.g.: "\
      "curl #{solr_url}/#{solr_collection}/update?commit=true"
    end

    private

    def do_import(tx_url = nil, commit = true)
      item_count = @import_delegate.total_number_of_items.to_i
      return if item_count < 1 # nothing to do

      task = Task.create!(name: @import_delegate.class.name,
                          status: Task::Status::RUNNING,
                          status_text: "Import #{item_count} items")

      begin
        @import_delegate.before_import(tx_url)

        item_count.times do |index|
          # retrieve or create the collection
          key = @import_delegate.collection_key_of_item_at_index(index)

          if @collections[key]
            collection = @collections[key]
          else
            collection = Repository::Collection.find_by_key(key)
          end
          unless collection
            collection = Repository::Collection.new(
                key: key,
                parent_url: @import_delegate.root_container_url,
                published: @import_delegate.collection_of_item_at_index_is_published(index),
                requested_slug: @import_delegate.slug_of_collection_of_item_at_index(index),
                rdf_graph: @import_delegate.metadata_of_collection_of_item_at_index(index),
                transaction_url: tx_url)
            Rails.logger.debug collection.title if collection.title
            collection.save!
            @collections[key] = collection
          end
          collection.transaction_url = tx_url

          # determine the resource URI under which the item will be created
          parent_import_id = @import_delegate.
              parent_import_id_of_item_at_index(index)
          parent_uri = @import_id_uri_map[parent_import_id]

          # create the item
          item = Repository::Item.new(
              collection: collection,
              parent_url: parent_uri || collection.repository_url,
              requested_slug: @import_delegate.slug_of_item_at_index(index),
              web_id: @import_delegate.web_id_of_item_at_index(index),
              parent_uri: parent_uri,
              rdf_graph: @import_delegate.metadata_of_item_at_index(index),
              transaction_url: tx_url)
          item.save! # save it in order to populate its repository URL
          Rails.logger.debug "Created #{item.repository_url} (#{index + 1}/#{item_count})"

          import_id = @import_delegate.import_id_of_item_at_index(index)
          @import_id_uri_map[import_id] = item.repository_url

          # append bytestream
          pathname = @import_delegate.master_pathname_of_item_at_index(index)
          if pathname
            if File.exists?(pathname)
              bs = Repository::Bytestream.new(
                  parent_url: item.repository_url,
                  upload_pathname: pathname,
                  transaction_url: tx_url)
              bs.type = Repository::Bytestream::Type::MASTER
              bs.shape = Repository::Bytestream::Shape::ORIGINAL
              media_type = @import_delegate.media_type_of_item_at_index(index)
              bs.media_type = media_type unless media_type.blank?
              bs.save!
              Rails.logger.debug "Created master bytestream"
            else
              Rails.logger.warn "#{pathname} does not exist"
            end
          else
            url = @import_delegate.master_url_of_item_at_index(index)
            if url
              bs = Repository::Bytestream.new(
                  parent_url: item.repository_url,
                  external_resource_url: url,
                  transaction_url: tx_url)
              bs.external_resource_url = url
              bs.type = Repository::Bytestream::Type::MASTER
              bs.shape = Repository::Bytestream::Shape::ORIGINAL
              media_type = @import_delegate.media_type_of_item_at_index(index)
              bs.media_type = media_type unless media_type.blank?
              bs.save!
              Rails.logger.debug "Created master bytestream URL"
            end
          end

          item.reload!
          item.full_text = @import_delegate.full_text_of_item_at_index(index)
          item.extract_and_update_full_text unless item.full_text.present?
          Rails.logger.debug "Added item full text"
          #item.generate_derivatives
          Rails.logger.debug "Added item bytestream derivatives"
          item.save!

          task.percent_complete = index / item_count.to_f
          task.save!
        end
      rescue => e
        task.status = Task::Status::FAILED
        task.save!
        raise e
      else
        Solr::Solr.client.commit if commit
        task.status = Task::Status::SUCCEEDED
        task.save!
      end
    end

  end

end
