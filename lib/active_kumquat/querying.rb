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
    # @param transaction_url string
    # @return Entity
    #
    def find(id, transaction_url = nil)
      self.find_by_uuid(id, transaction_url)
    end

    ##
    # @param uri Fedora resource URI
    # @param transaction_url string
    # @return Entity
    #
    def find_by_uri(uri, transaction_url = nil)
      self.where(id: "\"#{uri}\"").use_transaction_url(transaction_url).first
    end

    ##
    # @param uuid string
    # @param transaction_url string
    # @return Entity
    #
    def find_by_uuid(uuid, transaction_url = nil)
      self.where(uuid: uuid).use_transaction_url(transaction_url).first
    end

    ##
    # @param web_id string
    # @param transaction_url string
    # @return Entity
    #
    def find_by_web_id(web_id, transaction_url = nil)
      self.where(Solr::Solr::WEB_ID_KEY => web_id).
          use_transaction_url(transaction_url).first
    end

    def method_missing(name, *args, &block)
      if [:count, :first, :limit, :order, :start, :where].include?(name.to_sym)
        ActiveKumquat::Entity.new(self).send(name, *args, &block)
      end
    end

    def none
      ActiveKumquat::Entity.new
    end

    def respond_to_missing?(method_name, include_private = false)
      [:first, :limit, :order, :start, :where].include?(method_name.to_sym)
    end

  end

end