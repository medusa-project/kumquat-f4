module ActiveKumquat

  module Querying

    ##
    # @return ActiveKumquat::Entity
    #
    def all
      ActiveKumquat::Entity.new(self)
    end

    ##
    # @param id UUID
    # @return Entity
    #
    def find(id)
      self.find_by_uuid(id)
    end

    ##
    # @param uri Fedora resource URI
    # @return Entity
    #
    def find_by_uri(uri)
      self.where(id: uri).first
    end

    ##
    # @param uuid string
    # @return Entity
    #
    def find_by_uuid(uuid)
      self.where(uuid: uuid).first
    end

    ##
    # @param web_id string
    # @return Entity
    #
    def find_by_web_id(web_id)
      self.where(Solr::Solr::WEB_ID_KEY => web_id).first
    end

    def method_missing(name, *args, &block)
      if [:count, :first, :limit, :order, :start, :where].include?(name.to_sym)
        ActiveKumquat::Entity.new(self).send(name, *args, &block)
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      [:first, :limit, :order, :start, :where].include?(method_name.to_sym)
    end

  end

end