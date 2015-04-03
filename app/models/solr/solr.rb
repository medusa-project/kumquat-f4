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
    MEDIA_TYPE_KEY = :kq_system_media_type
    PAGE_INDEX_KEY = :kq_system_page_index
    PARENT_URI_KEY = :kq_system_parent_uri
    PUBLISHED_KEY = :kq_system_published
    WEB_ID_KEY = :kq_system_web_id
    WIDTH_KEY = :kq_system_width

    @@client = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url] +
                                 '/' + Kumquat::Application.kumquat_config[:solr_collection])

    ##
    # @return RSolr
    #
    def self.client
      @@client
    end

  end

end
