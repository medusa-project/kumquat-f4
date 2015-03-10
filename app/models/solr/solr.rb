module Solr

  class Solr

    BYTESTREAM_TYPE_KEY = :kq_system_bytestream_type
    COLLECTION_KEY_KEY = :kq_system_collection_key
    ENTITY_TYPE_KEY = :kq_system_resource_type
    HEIGHT_KEY = :kq_system_height
    MEDIA_TYPE_KEY = :kq_system_media_type
    PAGE_INDEX_KEY = :kq_system_page_index
    PARENT_UUID_KEY = :kq_system_parent_uuid
    RESOURCE_TYPE_KEY = ENTITY_TYPE_KEY
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
