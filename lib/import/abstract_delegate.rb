module Import

  ##
  # An abstract class that concrete implementations should extend. Importer
  # will call the methods of this class in a loop, total_number_of_items()
  # times.
  #
  # For the purposes of your implementation, it is guaranteed that every method
  # will be called with the same index parameter before it is incremented. It is
  # not, however, guaranteed that methods will be called in any particular
  # order.
  #
  # If you are importing any "compound items," e.g. items that have pages
  # a.k.a. sub-items a.k.a. child items, the parent item must be imported first,
  # which is to say it must have a lower index than any of its children.
  #
  # At any point, raising an error will terminate the import.
  #
  class AbstractDelegate

    ##
    # Should return the root container URL. Can also return nil, in which case
    # :fedora_url from the config file will be used.
    #
    # This method is optional.
    #
    # @return string
    #
    def root_container_url
      Kumquat::Application.kumquat_config[:fedora_url]
    end

    ##
    # Should return the total number of items being imported, including compound
    # item pages.
    #
    # @return integer
    #
    def total_number_of_items
      raise NotImplementedError, 'Must override total_number_of_items()'
    end

    ##
    # Should return a unique key for the collection of the object at the given
    # index. If a collection with the given key does not yet exist, it will be
    # created.
    #
    # It is recommended that imported objects not be added to existing
    # collections. (They can always be moved later.)
    #
    # @param index integer
    # @return hash
    #
    def collection_key_of_item_at_index(index)
      raise NotImplementedError, 'Must override collection_key_of_item_at_index()'
    end

    ##
    # Should return whether the collection of the item at the given index is
    # published; true or false.
    #
    # This method is optional.
    #
    # @param index integer
    # @return boolean
    #
    def collection_of_item_at_index_is_published(index)
      true
    end

    ##
    # Should return the full text of the item at the given index, or nil if the
    # item does not have any.
    #
    # This method is optional.
    #
    # @param index integer
    # @return string
    #
    def full_text_of_item_at_index(index)
    end

    ##
    # The import identifier is an arbitrary string that uniquely identifies an
    # item being imported. Its format is not important.
    #
    # @param index integer
    # @return string
    #
    def import_id_of_item_at_index(index)
      raise NotImplementedError,
            'Must override import_id_of_item_at_index()'
    end

    ##
    # Should return the import identifier of the parent item of the item at
    # the given index, or nil if the object has no parent item.
    #
    # Note that in order for this method to work, the parent item must be
    # imported before any of the children - i.e. it must have a lower index.
    #
    # This method is optional.
    #
    # @param index integer
    # @return string
    #
    def parent_import_id_of_item_at_index(index)
    end

    ##
    # Should return the absolute path of the master bytestream (file) being
    # imported at the given index.
    #
    # This method is optional.
    #
    # @param index integer
    # @return string
    #
    def master_pathname_of_item_at_index(index)
    end

    ##
    # Should return the URL of the master bytestream (file) being imported at
    # the given index. Implement this only if the item's bytestream resides at
    # a stable URL and is not to be managed by the repository.
    #
    # This method will only be called if master_pathname_of_item_at_index
    # returns nil, and is optional.
    #
    # @param index integer
    # @return string
    #
    def master_url_of_item_at_index(index)
    end

    ##
    # @param index integer
    # @return RDF::Graph
    #
    def metadata_of_collection_of_item_at_index(index)
      raise NotImplementedError,
            'Must override metadata_of_collection_of_item_at_index()'
    end

    ##
    # @param index integer
    # @return RDF::Graph
    #
    def metadata_of_item_at_index(index)
      raise NotImplementedError, 'Must override metadata_of_item_at_index()'
    end

    ##
    # Should return the IANA media type
    # (https://www.iana.org/assignments/media-types/media-types.xhtml) of the
    # item at the given index, if known. It's also okay to return nil, in which
    # case the media type will be guessed. The guessing is pretty reliable for
    # common file types.
    #
    # This method is optional.
    #
    # @param index integer
    # @return string
    #
    def media_type_of_item_at_index(index)
    end

    ##
    # Should return a URL slug that the repository should use for the given
    # collection resource. Can also return nil, in which case the collection
    # resource will receive an opaque URL/URI.
    #
    # Note that this is only a request; the repository is not guaranteed to
    # actually assign the slug.
    #
    # This method is optional.
    #
    # @param index integer
    # @return string
    #
    def slug_of_collection_of_item_at_index(index)
    end

    ##
    # Should return a URL slug that the repository should use for the given
    # item resource. Can also return nil, in which case the item resource
    # will receive an opaque URL/URI.
    #
    # Note that this is only a request; the repository is not guaranteed to
    # actually assign the slug.
    #
    # This method is optional.
    #
    # @param index integer
    # @return string
    #
    def slug_of_item_at_index(index)
    end

    ##
    # Should return a "web id" that the will be used in the item's URL. Can
    # also return nil, in which case the item will receive a random
    # alphanumeric web ID.
    #
    # Note that this is only a request; the repository is not guaranteed to
    # actually assign the web ID.
    #
    # This method is optional.
    #
    # @param index integer
    # @return string
    #
    def web_id_of_item_at_index(index)
    end

  end

end
