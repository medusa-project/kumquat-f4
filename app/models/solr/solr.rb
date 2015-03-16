module Solr

  class Solr

    # each of these requires a localized label (solr_field_*)
    FACET_FIELDS = [:kq_contributor_facet, :kq_coverage_facet,
                    :kq_creator_facet, :kq_date_facet, :kq_format_facet,
                    :kq_language_facet, :kq_publisher_facet, :kq_source_facet,
                    :kq_subject_facet, :kq_type_facet]

    CLASS_KEY = :kq_system_class
    COLLECTION_KEY_KEY = :kq_system_collection_key
    FULL_TEXT_KEY = :kq_system_full_text
    HEIGHT_KEY = :kq_system_height
    MASTER_BYTESTREAM_URI_KEY = :kq_system_master_bytestream_uri
    MEDIA_TYPE_KEY = :kq_system_media_type
    PAGE_INDEX_KEY = :kq_system_page_index
    PARENT_UUID_KEY = :kq_system_parent_uuid
    WEB_ID_KEY = :kq_system_web_id
    WIDTH_KEY = :kq_system_width

    def initialize
      @http = HTTPClient.new
      @url = Kumquat::Application.kumquat_config[:solr_url].chomp('/')
      @collection = Kumquat::Application.kumquat_config[:solr_collection]
    end

    def commit
      @http.get("#{@url}/#{@collection}/update?commit=true")
    end

  end

end
