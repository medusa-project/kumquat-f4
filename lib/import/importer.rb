module Import

  class Importer

    ##
    # @param import_delegate ImportDelegate
    #
    def initialize(import_delegate)
      @import_delegate = import_delegate
      @import_id_uri_map = {} # map of import IDs => repository URIs
      @collections = {} # map of collection keys => collections
    end

    def import
      item_count = @import_delegate.total_number_of_items.to_i
      return if item_count < 1 # nothing to do

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
              container_url: @import_delegate.root_container_url,
              published: @import_delegate.collection_of_item_at_index_is_published(index),
              requested_slug: @import_delegate.slug_of_collection_of_item_at_index(index),
              rdf_graph: @import_delegate.metadata_of_collection_of_item_at_index(index))
          Rails.logger.debug collection.title if collection.title
          collection.save!
          @collections[key] = collection
        end

        # determine the resource URI under which the item will be created
        parent_uri = nil
        parent_import_id = @import_delegate.
            parent_import_id_of_item_at_index(index)
        parent_uri ||= @import_id_uri_map[parent_import_id]

        # create the item
        item = Repository::Item.new(
            collection: collection,
            container_url: parent_uri || collection.repository_url,
            full_text: @import_delegate.full_text_of_item_at_index(index),
            requested_slug: @import_delegate.slug_of_item_at_index(index),
            web_id: @import_delegate.web_id_of_item_at_index(index),
            parent_uri: parent_uri,
            rdf_graph: @import_delegate.metadata_of_item_at_index(index))
        item.save! # save it in order to populate its repository URL
        Rails.logger.debug item.repository_url

        import_id = @import_delegate.import_id_of_item_at_index(index)
        @import_id_uri_map[import_id] = item.repository_url

        # append bytestream
        pathname = @import_delegate.master_pathname_of_item_at_index(index)
        if pathname
          if File.exists?(pathname)
            bs = Repository::Bytestream.new(
                owner: item,
                upload_pathname: pathname,
                type: Repository::Bytestream::Type::MASTER)
            # assign media type
            media_type = @import_delegate.media_type_of_item_at_index(index)
            bs.media_type = media_type if media_type
            bs.save
            item.bytestreams << bs
          else
            Rails.logger.warn "#{pathname} does not exist"
          end
        else
          url = @import_delegate.master_url_of_item_at_index(index)
          if url
            bs = Repository::Bytestream.new(
                owner: item,
                external_resource_url: url,
                type: Repository::Bytestream::Type::MASTER)
            # assign media type
            media_type = @import_delegate.media_type_of_item_at_index(index)
            bs.media_type = media_type if media_type
            bs.save
            item.bytestreams << bs
          end
        end

        item.generate_derivatives
        item.save!
      end
    end

  end

end
