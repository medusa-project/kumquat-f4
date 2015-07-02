module Indexable

  extend ActiveSupport::Concern

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
      if !pred.start_with?(Kumquat::NAMESPACE_URI) and
          !pred.start_with?('http://fedora.info') and # TODO: use Repository::Fedora::MANAGED_PREDICATES
          !obj.start_with?('http://fedora.info')
        doc[field_name_for_predicate(pred)] = st.object.to_s
      end
    end

    doc
  end

  def delete_from_solr
    Solr::Solr.client.delete_by_id(self.repository_url)
  end

  private

  ##
  # Gets the Solr-compatible field name for a given predicate.
  #
  # @param predicate [String]
  #
  def field_name_for_predicate(predicate)
    # convert all non-alphanumerics to underscores and then replace
    # repeating underscores with a single underscore
    'uri_' + predicate.to_s.gsub(/[^0-9a-z ]/i, '_').gsub(/\_+/, '_') + '_txt'
  end

end
