module ItemsHelper

  ##
  # @param item [Repository::Item]
  # @param options [Hash] with available keys: `:for_admin` (boolean)
  #
  def download_button(item, options = {})
    return nil unless item.master_bytestream
    html = '<div class="btn-group">
      <button type="button" class="btn btn-default dropdown-toggle"
           data-toggle="dropdown" aria-expanded="false">
        <i class="fa fa-download"></i> Download <span class="caret"></span>
      </button>'
    html += '<ul class="dropdown-menu pull-right" role="menu">'
    html += '<li>'
    html += link_to(download_label_for_bytestream(item.master_bytestream),
                    repository_item_master_bytestream_url(item))
    html += '</li>'
    derivatives = item.bytestreams.
        select{ |b| b.type == Repository::Bytestream::Type::DERIVATIVE }
    if derivatives.any?
      html += '<li class="divider"></li>'
      derivatives.each do |bs|
        html += '<li>'
        html += link_to(bytestream_url(bs)) do
          download_label_for_bytestream(bs)
        end
        html += '</li>'
      end
    end
    if options[:for_admin]
      json_ld_url = admin_repository_item_url(item, format: :jsonld)
      rdf_xml_url = admin_repository_item_url(item, format: :rdfxml)
      ttl_url = admin_repository_item_url(item, format: :ttl)
    else
      json_ld_url = repository_item_url(item, format: :jsonld)
      rdf_xml_url = repository_item_url(item, format: :rdfxml)
      ttl_url = repository_item_url(item, format: :ttl)
    end
    html += '<li class="divider"></li>'
    html += '<li>' + link_to('JSON-LD', json_ld_url) + '</li>'
    html += '<li>' + link_to('RDF/XML', rdf_xml_url) + '</li>'
    html += '<li>' + link_to('Turtle', ttl_url) + '</li>'
    html += '</ul>'
    html += '</div>'
    raw(html)
  end

  ##
  # @param items [ActiveMedusa::Relation]
  # @param options [Hash] Options hash.
  # @option options [Boolean] :show_collection_facet
  # @option options [MetadataProfile] :metadata_profile
  #
  def facets_as_panels(items, options = {})
    return nil unless items.facet_fields # nothing to do

    # get the list of facets to display from the provided metadata profile; or,
    # if not supplied, the default profile.
    profile = options[:metadata_profile] ||
        MetadataProfile.where(default: true).limit(1).first
    virtual_collection_triple = Triple.new(facet: Facet.find_by_name('Collection'),
                                           facet_label: 'Collection')
    profile_facetable_triples = [virtual_collection_triple] +
        profile.triples.where('facet_id IS NOT NULL').order(:index)

    term_limit = Option::integer(Option::Key::FACET_TERM_LIMIT)

    html = ''
    profile_facetable_triples.each do |triple|
      result_facet = items.facet_fields.
          select{ |f| f.field == triple.facet.solr_field }.first
      next unless result_facet and
          result_facet.terms.select{ |t| t.count > 0 }.any?
      next if result_facet.field == 'kq_collection_facet' and
          !options[:show_collection_facet]
      panel = "<div class=\"panel panel-default\">
      <div class=\"panel-heading\">
        <h3 class=\"panel-title\">#{triple.facet_label}</h3>
      </div>
      <div class=\"panel-body\">
        <ul>"
      result_facet.terms.each_with_index do |term, i|
        break if i >= term_limit
        next if term.count < 1
        checked = (params[:fq] and params[:fq].include?(term.facet_query)) ?
            'checked' : nil
        checked_params = term.removed_from_params(params.deep_dup)
        unchecked_params = term.added_to_params(params.deep_dup)

        if result_facet.field == 'kq_collection_facet'
          collection = Repository::Collection.find_by_uri(term.name)
          term_label = collection.title if collection
        else
          term_label = term.label
        end

        panel += "<li class=\"kq-term\">"
        panel += "<div class=\"checkbox\">"
        panel += "<label>"
        panel += "<input type=\"checkbox\" name=\"psap-facet-term\" #{checked} "\
        "data-checked-href=\"#{url_for(unchecked_params)}\" "\
        "data-unchecked-href=\"#{url_for(checked_params)}\">"
        panel += "<span class=\"kq-term-name\">#{term_label}</span> "
        panel += "<span class=\"kq-count badge\">#{term.count}</span>"
        panel += "</label>"
        panel += "</div>"
        panel += "</li>"
      end
      html += panel + '</ul></div></div>'
    end
    raw(html)
  end

  ##
  # @param describable [Describable]
  # @return [String] HTML <i> tag
  #
  def icon_for(describable)
    icon = 'fa-cube'
    if describable.class.to_s == 'Repository::Item' # TODO: why doesn't describable.kind_of?(Repository::Item) work?
      if describable.is_audio?
        icon = 'fa-volume-up'
      elsif describable.is_image?
        icon = 'fa-picture-o'
      elsif describable.is_pdf? or describable.is_text?
        icon = 'fa-file-text-o'
      elsif describable.is_video?
        icon = 'fa-film'
      elsif describable.items.any?
        icon = 'fa-cubes'
      end
    elsif describable.class.to_s == 'Repository::Collection' or # TODO: why doesn't describable.kind_of?(Repository::Collection) work?
        describable == Repository::Collection
      icon = 'fa-folder-open-o'
    end
    raw("<i class=\"fa #{icon}\"></i>")
  end

  ##
  # @param item [Repository::Item]
  #
  def is_favorite?(item)
    cookies[:favorites] and cookies[:favorites].
        split(FavoritesController::COOKIE_DELIMITER).
        select{ |f| f == item.web_id }.any?
  end

  ##
  # @param items [ActiveMedusa::Relation]
  # @param start [integer]
  # @param options [Hash] with available keys:
  # :link_to_admin (boolean), :show_remove_from_favorites_buttons (boolean),
  # :show_add_to_favorites_buttons (boolean),
  # :show_collections (boolean), :show_description (boolean),
  # :thumbnail_size (integer),
  # :thumbnail_shape (Repository::Bytestream::Shape constant)
  #
  def items_as_list(items, start, options = {})
    options[:show_description] = true unless
        options.keys.include?(:show_description)
    options[:thumbnail_shape] = Repository::Bytestream::Shape::ORIGINAL unless
        options.keys.include?(:thumbnail_shape)

    html = "<ol start=\"#{start + 1}\">"
    items.each do |entity|
      link_target = options[:link_to_admin] ?
          admin_repository_item_path(entity) : polymorphic_path(entity)
      html += '<li>'\
        '<div>'
      html += link_to(link_target, class: 'kq-thumbnail-link') do
        if entity.class.to_s == 'Repository::Collection' # TODO: why does entity.kind_of?(Repository::Collection) return false?
          media_types = "(#{Derivable::TYPES_WITH_IMAGE_DERIVATIVES.join(' OR ')})"
          item = Repository::Item.
              where("{!join from=#{Solr::Fields::ITEM} to=#{Solr::Fields::ID}}#{Solr::Fields::MEDIA_TYPE}:(#{media_types})").
              filter(Solr::Fields::COLLECTION => entity.id).
              omit_entity_query(true).
              facet(false).order("random_#{SecureRandom.hex}").limit(1).first
          item ||= Repository::Collection
        else
          item = entity
        end
        raw('<div class="kq-thumbnail">' +
          thumbnail_tag(item,
                        options[:thumbnail_size] ? options[:thumbnail_size] : 256,
                        options[:thumbnail_shape]) +
        '</div>')
      end
      html += '<span class="kq-title">'
      html += link_to(entity.title, link_target)
      if options[:show_remove_from_favorites_buttons] and
          entity.kind_of?(Repository::Item)
        html += ' <button class="btn btn-xs btn-danger ' +
            'kq-remove-from-favorites" data-web-id="' + entity.web_id + '">'
        html += '<i class="fa fa-heart"></i> Remove'
        html += '</button>'
      end
      if options[:show_add_to_favorites_buttons] and
          entity.kind_of?(Repository::Item)
        html += ' <button class="btn btn-default btn-xs ' +
            'kq-add-to-favorites" data-web-id="' + entity.web_id + '">'
        html += '<i class="fa fa-heart-o"></i>'
        html += '</button>'
      end
      html += '</span>'
      if options[:show_collections] and entity.class.to_s == 'Repository::Item' # TODO: why does entity.kind_of?(Repository::Item) return false?
        html += '<br>'
        html += link_to(entity.collection) do
          raw("#{self.icon_for(entity.collection)} #{entity.collection.title}")
        end
      end
      if options[:show_description]
        html += '<br>'
        html += '<span class="kq-description">'
        html += truncate(entity.description.to_s, length: 400)
        html += '</span>'
      end
      html += '</div>'
      html += '</li>'
    end
    html += '</ol>'
    raw(html)
  end

  ##
  # @param search_term [String]
  # @param suggestions [Array<String>]
  # @return [String] HTML string
  #
  def no_results_help(search_term, suggestions)
    html = ''
    if search_term.present?
      html += "<p class=\"alert alert-warning\">Sorry, we couldn't find "\
      "anything matching &quot;#{h(search_term)}&quot;.</p>"
      if suggestions.any?
        html += "<p>Did you mean:</p><ul>"
        suggestions.each do |suggestion|
          html += "<li>#{link_to(suggestion, { q: suggestion })}?</li>"
        end
        html += '</ul>'
      end
    else
      html += '<p>No items.</p>'
    end
    raw(html)
  end

  ##
  # @return [Integer]
  #
  def num_favorites
    cookies[:favorites] ?
        cookies[:favorites].split(FavoritesController::COOKIE_DELIMITER).length : 0
  end

  ##
  # @param item [Repository::Item]
  # @param options [Hash] with available keys: `:link_to_admin` [Boolean]
  #
  def pages_as_list(item, options = {})
    return nil unless item.items.any? or item.parent_item
    items = item.items.any? ? item.items : item.parent_item.items
    html = '<ol>'
    items.each do |child|
      link_target = options[:link_to_admin] ?
          admin_repository_item_path(child) : repository_item_path(child)
      html += '<li><div>'
      if item == child
        html += raw('<div class="kq-thumbnail">' +
            thumbnail_tag(child, 256) +
            '</div>')
        html += "<strong class=\"kq-text kq-title\">#{truncate(child.title, length: 40)}</strong>"
      else
        html += link_to(link_target) do
          raw('<div class="kq-thumbnail">' + thumbnail_tag(child, 256) + '</div>')
        end
        html += link_to(truncate(child.title, length: 40), link_target,
                        class: 'kq-title')
      end
      html += '</div></li>'
    end
    html += '</ol>'
    raw(html)
  end

  ##
  # @param items [Array]
  # @param per_page [Integer]
  # @param current_page [Integer]
  # @param max_links [Integer] (ideally odd)
  #
  def paginate(items, per_page, current_page, max_links = 9)
    return '' unless items.total_length > per_page
    num_pages = (items.total_length / per_page.to_f).ceil
    first_page = [1, current_page - (max_links / 2.0).floor].max
    last_page = [first_page + max_links - 1, num_pages].min
    first_page = last_page - max_links + 1 if
        last_page - first_page < max_links and num_pages > max_links
    prev_page = [1, current_page - 1].max
    next_page = [last_page, current_page + 1].min
    prev_start = (prev_page - 1) * per_page
    next_start = (next_page - 1) * per_page
    last_start = (num_pages - 1) * per_page

    first_link = link_to(params.except(:start), 'aria-label' => 'First') do
      raw('<span aria-hidden="true">First</span>')
    end
    prev_link = link_to(params.merge(start: prev_start), 'aria-label' => 'Previous') do
      raw('<span aria-hidden="true">&laquo;</span>')
    end
    next_link = link_to(params.merge(start: next_start), 'aria-label' => 'Next') do
      raw('<span aria-hidden="true">&raquo;</span>')
    end
    last_link = link_to(params.merge(start: last_start), 'aria-label' => 'Last') do
      raw('<span aria-hidden="true">Last</span>')
    end

    # http://getbootstrap.com/components/#pagination
    html = '<nav>' +
      '<ul class="pagination">' +
        "<li #{current_page == first_page ? 'class="disabled"' : ''}>#{first_link}</li>" +
        "<li #{current_page == prev_page ? 'class="disabled"' : ''}>#{prev_link}</li>"
    (first_page..last_page).each do |page|
      start = (page - 1) * per_page
      page_link = link_to((start == 0) ? params.except(:start) : params.merge(start: start)) do
        raw("#{page} #{(page == current_page) ?
                '<span class="sr-only">(current)</span>' : ''}")
      end
      html += "<li class=\"#{page == current_page ? 'active' : ''}\">" +
            page_link + '</li>'
    end
    html += "<li #{current_page == next_page ? 'class="disabled"' : ''}>#{next_link}</li>" +
        "<li #{current_page == last_page ? 'class="disabled"' : ''}>#{last_link}</li>"
      '</ul>' +
    '</nav>'
    raw(html)
  end

  ##
  # Returns the status of a search or browse action, e.g. "Showing n of n
  # items".
  #
  # @param items [ActiveMedusa::Relation]
  # @param start [Integer]
  # @param num_results_shown [Integer]
  # @return [String]
  #
  def search_status(items, start, num_results_shown)
    total = items.total_length
    last = [total, start + num_results_shown].min
    raw("Showing #{start + 1}&ndash;#{last} of #{total} items")
  end

  ##
  # @param item [Repository::Item]
  # @return [String] HTML string
  #
  def share_button(item)
    html = '<div class="btn-group">
      <button type="button" class="btn btn-default dropdown-toggle"
            data-toggle="dropdown" aria-expanded="false">
        <i class="fa fa-share-alt"></i> Share <span class="caret"></span>
      </button>'
    html += '<ul class="dropdown-menu pull-right" role="menu">'
    description = item.description ? CGI::escape(item.description) : nil
    # email
    html += '<li>'
    html += link_to("mailto:?subject=#{item.title}&body=#{repository_item_url(item)}") do
      raw('<i class="fa fa-envelope"></i> Email')
    end
    html += '</li>'
    html += '<li class="divider"></li>'
    # facebook
    html += '<li>'
    html += link_to("https://www.facebook.com/sharer/sharer.php?u=#{CGI::escape(repository_item_url(item))}") do
      raw('<i class="fa fa-facebook-square"></i> Facebook')
    end
    html += '</li>'
    # linkedin
    html += '<li>'
    html += link_to("http://www.linkedin.com/shareArticle?mini=true&url=#{CGI::escape(repository_item_url(item))}&title=#{CGI::escape(item.title)}&summary=#{description}") do
      raw('<i class="fa fa-linkedin-square"></i> LinkedIn')
    end
    html += '</li>'
    # twitter
    html += '<li>'
    html += link_to("http://twitter.com/home?status=#{CGI::escape(item.title)}%20#{CGI::escape(repository_item_url(item))}") do
      raw('<i class="fa fa-twitter-square"></i> Twitter')
    end
    html += '</li>'
    # google+
    html += '<li>'
    html += link_to("https://plus.google.com/share?url=#{CGI::escape(item.title)}%20#{CGI::escape(repository_item_url(item))}") do
      raw('<i class="fa fa-google-plus-square"></i> Google+')
    end
    html += '</li>'
    # pinterest
    url = "http://pinterest.com/pin/create/button/?url=#{CGI::escape(repository_item_url(item))}&description=#{CGI::escape(item.title)}"
    bs = item.derivative_image(512)
    url += "&media=#{CGI::escape(bytestream_url(bs))}" if bs
    html += '<li>'
    html += link_to(url) do
      raw('<i class="fa fa-pinterest-square"></i> Pinterest')
    end
    html += '</li>'

    html += '</ul>'
    html += '</div>'
    raw(html)
  end

  ##
  # @param item [Repository::Item]
  # @param limit [Integer]
  # @return [String] HTML unordered list
  #
  def similar_items_as_list(item, limit = 5)
    html = ''
    items = item.more_like_this.limit(limit)
    if items.any?
      html += '<ul>'
      items.each do |item|
        html += '<li>'
        html += '<div class="kq-thumbnail">'
        html += link_to(repository_item_path(item)) do
          thumbnail_tag(item, 256, Repository::Bytestream::Shape::SQUARE)
        end
        html += '</div>'
        html += link_to(truncate(item.title, length: 40),
                        repository_item_path(item), class: 'kq-title')
        html += '</li>'
      end
      html += '</ul>'
    end
    raw(html)
  end

  ##
  # @param entity [Repository::Item] or some other object suitable for passing
  # to `icon_for`
  # @param size [Integer] One of the sizes in `Derivable::IMAGE_DERIVATIVES`
  # @param shape [String] One of the `Repository::Bytestream::Shape` constants
  # @return [String]
  #
  def thumbnail_tag(entity, size,
                    shape = Repository::Bytestream::Shape::ORIGINAL)
    html = ''
    if entity.class.to_s == 'Repository::Item' # TODO: why doesn't entity.kind_of?(Repository::Item) work?
      bs = entity.derivative_image(size, shape)
      if bs
        # no alt because it may appear in a huge font size if the image is 404
        # for some reason
        html += image_tag(bytestream_url(bs), alt: '')
      else
        html += self.icon_for(entity)
      end
    else
      html += self.icon_for(entity)
    end
    raw(html)
  end

  ##
  # Returns an HTML definition list of all triples associated with the given
  # `Describable`, according to the settings of the given `MetadataProfile`.
  #
  # @param describable [Describable]
  # @param options [Hash] Options hash.
  # @option options [Boolean] :full_label_info
  # @option options [MetadataProfile] :metadata_profile If nil, the default
  #   profile will be used.
  # @return [String] HTML definition list element
  #
  def triples_as_dl(describable, options = {})
    triples = processed_triples(describable, options)

    html = '<dl class="kq-triples">'
    triples.each do |triple|
      next unless triple[:objects].select{ |o| !o.strip.blank? }.any?
      html += "<dt>#{triple[:label]}</dt>"
      html += triple[:objects].map{ |object| "<dd>#{object}</dd>" }.join
    end
    html += '</dl>'
    raw(html)
  end

  ##
  # Returns an HTML table of all triples associated with the given
  # `Describable`, according to the settings of the given `MetadataProfile`.
  #
  # @param describable [Describable]
  # @param options [Hash] Options hash.
  # @option options [Boolean] :full_label_info
  # @option options [MetadataProfile] :metadata_profile If nil, the default
  #   profile will be used.
  # @return [String] HTML table element
  #
  def triples_as_table(describable, options = {})
    triples = processed_triples(describable, options)

    html = '<table class="table table-condensed kq-triples">'
    triples.each do |triple|
      next unless triple[:objects].select{ |o| !o.strip.blank? }.any?
      html += '<tr>'
      if options[:full_label_info]
        html += "<td>#{triple[:label]}</td>"
      else
        html += "<td>#{triple[:label] || triple[:prefixed_predicate] ||
            triple[:predicate]}</td>"
      end
      if options[:full_label_info]
        html += "<td>#{triple[:prefixed_predicate] || triple[:predicate]}</td>"
      end
      html += '<td>'
      if triple[:objects].length > 1
        html += '<ul>'
        html += triple[:objects].map { |object| "<li>#{object}</li>" }.join
        html += '</ul>'
      elsif triple[:objects].length == 1
        html += auto_link(triple[:objects].first.strip)
      end
      html += '</td></tr>'
    end
    html += '</table>'
    raw(html)
  end

  ##
  # @param item [Repository::Item]
  #
  def viewer_for(item)
    if item.is_pdf?
      return pdf_viewer_for(item)
    elsif item.is_image?
      return image_viewer_for(item)
    elsif item.is_audio?
      return audio_player_for(item)
    elsif item.is_text?
      # We don't provide a viewer for text as this is handled separately in
      # show-item view by reading the item's full_text property. Full text and
      # a viewer are not mutually exclusive -- an image may have full text, an
      # audio clip may have a transcript, etc.
    elsif item.is_video?
      return video_player_for(item)
    end
    nil
  end

  private

  def audio_player_for(item)
    tag = "<audio controls>
      <source src=\"#{bytestream_url(item.master_bytestream)}\"
              type=\"#{item.master_bytestream.media_type}\">
        Your browser does not support the audio tag.
    </audio>"
    raw(tag)
  end

  def image_viewer_for(item)
    html = "<div id=\"kq-image-viewer\"></div>
    #{javascript_include_tag('/openseadragon/openseadragon.min.js')}
    <script type=\"text/javascript\">
    var viewer = OpenSeadragon({
        id: \"kq-image-viewer\",
        preserveViewport: true,
        prefixUrl: \"/openseadragon/images/\",
        tileSources: [{
            \"@context\": \"http://library.stanford.edu/iiif/image-api/1.1/context.json\",
            \"@id\": \"#{j(item.image_iiif_url)}\",
            \"formats\": [ \"jpg\", \"png\", \"gif\", \"webp\" ],
            \"height\": #{j(item.master_image.height.to_s)},
            \"profile\": \"http://library.stanford.edu/iiif/image-api/1.1/compliance.html#level2\",
            \"qualities\": [ \"default\", \"bitonal\", \"gray\", \"color\" ],
            \"scale_factors\": [1, 2, 4, 8, 16],
            \"tile_height\": 256,
            \"tile_width\": 256,
            \"width\": #{j(item.master_image.width.to_s)}
        }]
    });
    </script>"
    raw(html)
  end

  def pdf_viewer_for(item)
    link_to(repository_item_master_bytestream_url(item)) do
      thumbnail_tag(item, 256)
    end
  end

  def video_player_for(item)
    tag = "<video controls id=\"kq-video-player\">
      <source src=\"#{bytestream_url(item.master_bytestream)}\"
              type=\"#{item.master_bytestream.media_type}\">
        Your browser does not support the video tag.
    </video>"
    raw(tag)
  end

  private

  def download_label_for_bytestream(bytestream)
    parts = []
    if bytestream.type == Repository::Bytestream::Type::MASTER
      parts << 'Master'
    end
    type = MIME::Types[bytestream.media_type].first
    if type and type.friendly
      parts << type.friendly
    elsif bytestream.media_type.present?
      parts << bytestream.media_type
    end
    if bytestream.width and bytestream.width > 0 and bytestream.height and
        bytestream.height > 0
      parts << "<small>#{bytestream.width}&times;#{bytestream.height}</small>"
    end
    if bytestream.byte_size
      parts << "<small>#{number_to_human_size(bytestream.byte_size)}</small>"
    end
    raw(parts.join(' | '))
  end

  def human_label_for_uri(describable, uri)
    if describable.class.to_s == 'Repository::Collection' # TODO: why does entity.kind_of?(Repository::Collection) return false?
      collection = describable
    else
      collection = describable.collection
    end
    triple = collection.db_counterpart.metadata_profile.triples.
        where(predicate: uri).first
    triple ? triple.label : nil
  end

  ##
  # @return [Array] Array of hashes with :label, :prefixed_predicate, and
  #   :objects keys.
  #
  def processed_triples(describable, options)
    exclude_uris = (Repository::Fedora::MANAGED_PREDICATES +
        [Kumquat::NAMESPACE_URI])
    profile = options[:metadata_profile] ||
        MetadataProfile.find_by_default(true)
    hidden_profile_predicates = profile.triples.where(visible: false).
        map{ |f| f.predicate }

    # process triples into an array of hashes, collapsing identical subjects
    triples = []
    describable.rdf_graph.each_statement do |statement|
      next if hidden_profile_predicates.include?(statement.predicate.to_s)
      triple = {
          predicate: statement.predicate.to_s,
          objects: []
      }
      # assemble a label for the predicate
      prefix = statement.predicate.prefix
      if prefix
        triple[:prefixed_predicate] = "#{prefix}:#{statement.predicate.term}"
      end
      triple[:label] = human_label_for_uri(describable, statement.predicate.to_s)
      triples << triple
    end
    describable.rdf_graph.each_statement do |statement|
      # Exclude certain predicates & objects from display
      next if exclude_uris.select{ |p| statement.predicate.to_s.start_with?(p) or
          statement.object.to_s.start_with?(p) }.any?
      triple = triples.
          select{ |t2| t2[:predicate] == statement.predicate.to_s }.first
      triple[:objects] << statement.object.to_s if triple and
          statement.object.to_s.present?
    end

    # sort the triples array according to the profile, putting undefined
    # triples last
    triples_in_order = profile.triples.order(:index)
    triples.sort! do |a, b|
      retval = 1
      t1 = triples_in_order.find_by_predicate(a[:predicate])
      if t1
        t2 = triples_in_order.find_by_predicate(b[:predicate])
        if t2
          retval = t1.index <=> t2.index
        else
          retval = 1
        end
      end
      retval
    end
    triples
  end

end
