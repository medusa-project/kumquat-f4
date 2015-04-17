module OaiPmhHelper

  ##
  # @param identifier string
  # @param host string
  # @return Repository::Item
  #
  def item_for_oai_pmh_identifier(identifier, host)
    parts = identifier.split(':')
    web_id = parts.pop
    return nil if parts.join(':') != "oai:#{host}"
    Repository::Item.find_by_web_id(web_id)
  end

  ##
  # @param item Repository::Item
  # @param host string
  # @return string
  #
  def oai_pmh_identifier_for(item, host)
    # see section 2.4: http://www.openarchives.org/OAI/openarchivesprotocol.html
    "oai:#{host}:#{item.web_id}"
  end

end