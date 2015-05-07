##
# Receives incoming requests from fcrepo-camel to add or remove items from the
# index (Solr). A more flexible alternative to Fedora indexing transformations.
#
class IndexController < ApplicationController

  protect_from_forgery with: :null_session

  before_action :check_access

  ##
  # Responds to POST /index
  #
  def update
    # The request body should be a JSON document:
    # [
    #   {
    #     "id":["http://localhost:8080/fedora/rest/audio-sample"],
    #     "title":["Sample Audio Collection"],
    #     "uuid":["6669dbb5-5dd8-402b-88f7-be6b0b00bb1f"]
    #   }
    # ]

    # extract the URI of the changed node from the request body
    struct = JSON.parse(request.body.read).first
    uri = struct['id'][0]

    # get the RDF content at the URI
    http = HTTPClient.new
    response = http.get(uri, nil, { 'Accept' => 'application/n-triples' })
    graph = RDF::Graph.new
    graph.from_ntriples(response.body)

    kq_ns = Kumquat::Application::NAMESPACE_URI
    kq_predicates = Kumquat::Application::RDFPredicates

    # initialize a document with some system-administered properties
    doc = {
        'id' => uri,
        Solr::Fields::UUID => struct['uuid'][0],
        Solr::Fields::CLASS => graph.any_object(kq_ns + kq_predicates::CLASS).to_s,
        Solr::Fields::COLLECTION_KEY => graph.any_object(kq_ns + kq_predicates::COLLECTION_KEY).to_s,
        Solr::Fields::CREATED_AT => graph.any_object('http://fedora.info/definitions/v4/repository#created').to_s,
        Solr::Fields::FULL_TEXT => graph.any_object(kq_ns + kq_predicates::FULL_TEXT).to_s,
        Solr::Fields::HEIGHT => graph.any_object(kq_ns + kq_predicates::HEIGHT).to_s,
        Solr::Fields::PAGE_INDEX => graph.any_object(kq_ns + kq_predicates::PAGE_INDEX).to_s,
        Solr::Fields::PARENT_URI => graph.any_object(kq_ns + kq_predicates::PARENT_URI).to_s,
        Solr::Fields::PUBLISHED => graph.any_object(kq_ns + kq_predicates::PUBLISHED).to_s,
        Solr::Fields::UPDATED_AT => graph.any_object('http://fedora.info/definitions/v4/repository#lastModified').to_s,
        Solr::Fields::WEB_ID => graph.any_object(kq_ns + kq_predicates::WEB_ID).to_s,
        Solr::Fields::WIDTH => graph.any_object(kq_ns + kq_predicates::WIDTH).to_s
    }

    # add node metadata to the document
    graph.each_statement do |statement|
      # exclude kumquat predicates (that we just added above into custom
      # fields) from the document
      next if statement.predicate.to_s.start_with?(kq_ns)
      # exclude repository-managed predicates from the document
      next if Repository::Fedora::MANAGED_PREDICATES.
          select{ |p| statement.predicate.to_s.start_with?(p) }.any?
      field_name = Solr::Solr.field_name_for_predicate(statement.predicate)
      doc[field_name] = statement.object.to_s

      # field_name fields are all multiValued, i.e. not sortable. We will
      # make the title sortable by copying only one title into a designated
      # non-multiValued title field.
      if %w(http://purl.org/dc/elements/1.1/title http://purl.org/dc/terms/title).
          include?(statement.predicate.to_s)
        doc[Solr::Fields::SINGLE_TITLE] = statement.object.to_s
      end
    end

    solr = Solr::Solr.client
    solr.add(doc)

    render text: '', status: 204
  end

  private

  ##
  # Restricts access to the fcrepo-camel host.
  #
  def check_access
    if Kumquat::Application.kumquat_config[:fcrepo_camel_ip] != request.remote_ip
      render text: 'Access denied. Check the value of :fcrepo_camel_ip in the '\
      'config file.', status: 403
    end
  end

end
