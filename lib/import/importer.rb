module Import

  class Importer

    ##
    # @param import_delegate ImportDelegate
    #
    def initialize(import_delegate)
      @import_delegate = import_delegate
      @import_id_uuid_map = {} # map of import IDs => repository UUIDs
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
          collection = Collection.find_by_key(key)
        end
        unless collection
          collection = Collection.new(
              key: key,
              container_url: @import_delegate.root_container_url,
              requested_slug: @import_delegate.slug_of_collection_of_item_at_index(index),
              rdf_graph: @import_delegate.metadata_of_collection_of_item_at_index(index))
          puts collection.title if collection.title
          collection.save!
          @collections[key] = collection
        end

        # create the item
        item = Item.new(collection: collection,
                        container_url: collection.repository_url,
                        full_text: @import_delegate.full_text_of_item_at_index(index),
                        requested_slug: @import_delegate.slug_of_item_at_index(index),
                        web_id: @import_delegate.web_id_of_item_at_index(index),
                        rdf_graph: @import_delegate.metadata_of_item_at_index(index))
        item.save! # save it in order to populate its UUID
        puts item.repository_url

        import_id = @import_delegate.import_id_of_item_at_index(index)
        @import_id_uuid_map[import_id] = item.uuid

        parent_import_id = @import_delegate.parent_import_id_of_item_at_index(index)
        if parent_import_id
          parent_uuid = @import_id_uuid_map[parent_import_id]
          item.parent_uuid = parent_uuid if parent_uuid
        end

        # append bytestream TODO: support URL items
        pathname = @import_delegate.master_pathname_of_item_at_index(index)
        if pathname and File.exists?(pathname)
          bs = Bytestream.new(owner: item,
                              upload_pathname: pathname,
                              type: Bytestream::Type::MASTER)
          # assign media type
          media_type = @import_delegate.media_type_of_item_at_index(index)
          bs.media_type = media_type if media_type
          bs.save
          item.bytestreams << bs
        else
          Rails.logger.warn "#{pathname} does not exist"
        end

        item.generate_derivatives
        item.save!
      end
    end

  end

end
