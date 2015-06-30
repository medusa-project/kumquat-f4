module Solr

  class Fields

    BYTE_SIZE = :kq_sys_byte_size_i
    BYTESTREAM_SHAPE = :kq_sys_bytestream_shape_s
    BYTESTREAM_TYPE = :kq_sys_bytestream_type_s
    CLASS = :kq_sys_class_s
    COLLECTION = :kq_sys_collection_s
    COLLECTION_KEY = :kq_sys_collection_key_s
    CREATED_AT = :kq_sys_created_at_dts
    DATE = :kq_meta_date_dts
    # each of these requires a localized label (solr_field_*)
    FACET_FIELDS = [:kq_collection_facet, :kq_contributor_facet,
                    :kq_coverage_facet, :kq_creator_facet, :kq_date_facet,
                    :kq_format_facet, :kq_language_facet, :kq_publisher_facet,
                    :kq_source_facet, :kq_subject_facet, :kq_type_facet]
    FULL_TEXT = :kq_sys_full_text_txt
    HEIGHT = :kq_sys_height_i
    MEDIA_TYPE = :kq_sys_media_type_s
    PAGE_INDEX = :kq_sys_page_index_i
    PARENT_URI = :kq_sys_parent_uri_s
    PUBLISHED = :kq_sys_published_b
    SEARCH_ALL = :kq_searchall_txt
    SINGLE_TITLE = :kq_meta_title_s
    UPDATED_AT = :kq_sys_updated_at_dts
    UUID = :kq_sys_uuid_s
    WEB_ID = :kq_sys_web_id_s
    WIDTH = :kq_sys_width_i

  end

end