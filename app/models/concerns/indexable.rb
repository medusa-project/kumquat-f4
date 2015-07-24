module Indexable

  extend ActiveSupport::Concern

  included do
    after_save :reindex
    after_save :delete_from_solr # TODO: this is a workaround for after_destroy not working
  end

  ##
  # Returns a base Solr document.
  #
  # @return [Hash] Hash suitable for passing to `RSolr.add()`
  #
  def base_solr_document
    kq_predicates = Kumquat::RDFPredicates

    doc = {
        'id' => self.repository_url,
        Solr::Fields::UUID => self.uuid,
        Solr::Fields::CLASS => self.class.entity_class_uri,
        Solr::Fields::CREATED_AT =>
            self.rdf_graph.any_object('http://fedora.info/definitions/v4/repository#created').to_s,
        Solr::Fields::PARENT_URI =>
            self.rdf_graph.any_object(kq_predicates::PARENT_URI),
        Solr::Fields::UPDATED_AT =>
            self.rdf_graph.any_object('http://fedora.info/definitions/v4/repository#lastModified').to_s
    }

    # add arbitrary triples
    self.rdf_graph.each_statement do |st|
      pred = st.predicate.to_s
      obj = st.object.to_s
      if Repository::Fedora::MANAGED_PREDICATES.select{ |p| pred.start_with?(p) or
          obj.start_with?(p) }.empty? and
          self.class.properties.map{ |p| p.rdf_predicate }.select{ |p| pred == p }.empty?
        doc[Solr::Solr::field_name_for_predicate(pred)] = obj
      end
    end

    doc
  end

  def delete_from_solr
    Solr::Solr.client.delete_by_id(self.repository_url) if self.destroyed?
  end

  def reindex
    raise 'Must implement reindex()'
  end

end
