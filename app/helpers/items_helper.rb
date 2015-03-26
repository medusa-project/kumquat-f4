module ItemsHelper

  PREFIXES = { # TODO: externalize this
      dc: 'http://purl.org/dc/elements/1.1/',
      dcterms: 'http://purl.org/dc/terms/'
  }

  def download_button(item)
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
        html += link_to(bs.repository_url) do
          download_label_for_bytestream(bs)
        end
        html += '</li>'
      end
    end
    html += '</ul>'
    html += '</div>'
    raw(html)
  end

  ##
  # @param items ActiveKumquat::ResultSet
  #
  def facets_as_panels(items)
    term_limit = Kumquat::Application.kumquat_config[:facet_term_limit]
    panels = ''
    items.facet_fields.each do |facet|
      panel = '<div class="panel panel-default">'
      next unless facet.terms.select{ |t| t.count > 0 }.any?
      panel += "<div class=\"panel-heading\">
        <h3 class=\"panel-title\">#{facet.label}</h3>
      </div>
      <div class=\"panel-body\">
        <ul>"
      facet.terms.each_with_index do |term, i|
        break if i >= term_limit
        next if term.count < 1
        term_params = params.deep_dup
        clear_link = nil
        if term_params[:fq] and term_params[:fq].include?(term.facet_query)
          term_params = term.removed_from_params(term_params)
          clear_link = link_to(term_params, class: 'kq-clear') do
            content_tag(:i, nil, class: 'fa fa-remove')
          end
          term_html = "<span class=\"kq-selected-term\">#{term.name}</span>"
        else
          term_html = link_to(term.name, term.added_to_params(term_params))
        end
        panel += "<li class=\"kq-term\">
          <span class=\"kq-term-name\">#{term_html}</span>
          <span class=\"kq-count badge\">#{term.count}</span>
          #{clear_link}
        </li>"
      end
      panels += panel + '</ul></div></div>'
    end
    raw(panels)
  end

  def icon_for(describable)
    icon = 'fa-cube'
    if describable.kind_of?(Repository::Item)
      if describable.is_audio?
        icon = 'fa-volume-up'
      elsif describable.is_image?
        icon = 'fa-picture-o'
      elsif describable.is_pdf? or describable.is_text?
        icon = 'fa-file-text-o'
      elsif describable.is_video?
        icon = 'fa-film'
      elsif describable.children.any?
        icon = 'fa-cubes'
      end
    elsif describable.kind_of?(Repository::Collection)
      icon = 'fa-folder-open-o'
    end
    raw("<i class=\"fa #{icon}\"></i>")
  end

  def is_favorite?(item)
    cookies[:favorites] and cookies[:favorites].
        split(FavoritesController::COOKIE_DELIMITER).
        select{ |f| f == item.web_id }.any?
  end

  ##
  # @param items ActiveKumquat::Entity
  # @param start integer
  # @param options Hash with available keys:
  # :show_remove_from_favorites_buttons, :show_add_to_favorites_buttons,
  # :show_collections, :show_description, :thumbnail_size
  #
  def items_as_list(items, start, options = {})
    html = "<ol start=\"#{start + 1}\">"
    items.each do |item|
      html += '<li>'\
        '<div>'
      if item.kind_of?(Repository::Item)
        html += link_to(item, class: 'kq-thumbnail-link') do
          thumbnail_tag(item,
                        options[:thumbnail_size] ? options[:thumbnail_size] : 256)
        end
      end
      html += '<span class="kq-title">'
      html += link_to(item.title, item)
      if options[:show_remove_from_favorites_buttons]
        html += ' <button class="btn btn-xs btn-danger ' +
            'kq-remove-from-favorites" data-web-id="' + item.web_id + '">'
        html += '<i class="fa fa-heart"></i> Remove'
        html += '</button>'
      end
      if options[:show_add_to_favorites_buttons]
        html += ' <button class="btn btn-default btn-xs ' +
            'kq-add-to-favorites" data-web-id="' + item.web_id + '">'
        html += '<i class="fa fa-heart-o"></i>'
        html += '</button>'
      end
      html += '</span>'
      if options[:show_collections]
        html += '<br>'
        html += link_to(item.collection) do
          raw("#{self.icon_for(item.collection)} #{item.collection.title}")
        end
      end
      if options[:show_description]
        html += '<br>'
        html += '<span class="kq-description">'
        html += truncate(item.description.to_s, length: 400)
        html += '</span>'
      end
      html += '</div>'
      html += '</li>'
    end
    html += '</ol>'
    raw(html)
  end

  ##
  # @return integer
  #
  def num_favorites
    cookies[:favorites] ?
        cookies[:favorites].split(FavoritesController::COOKIE_DELIMITER).length : 0
  end

  ##
  # @param item Repository::Item
  #
  def pages_as_list(item)
    return nil unless item.children.any? or item.parent
    items = item.children.any? ? item.children : item.parent.children
    html = '<ol>'
    items.each do |child|
      html += '<li><div>'
      if item == child
        html += thumbnail_tag(child, 256)
        html += "<strong class=\"kq-text\">#{truncate(child.title, length: 40)}</strong>"
      else
        html += link_to(child) do
          thumbnail_tag(child, 256)
        end
        html += link_to(truncate(child.title, length: 40), child)
      end
      html += '</div></li>'
    end
    html += '</ol>'
    raw(html)
  end

  ##
  # @param items array
  # @param per_page integer
  # @param current_page integer
  # @param max_links integer (ideally odd)
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

  def share_button(item)
    html = '<div class="btn-group">
      <button type="button" class="btn btn-default dropdown-toggle"
            data-toggle="dropdown" aria-expanded="false">
        <i class="fa fa-share-alt"></i> Share <span class="caret"></span>
      </button>'
    html += '<ul class="dropdown-menu pull-right" role="menu">'
    # email
    html += '<li>'
    html += link_to("mailto:?subject=#{CGI::escape(item.title)}") do
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
    html += link_to("http://www.linkedin.com/shareArticle?mini=true&url=#{CGI::escape(repository_item_url(item))}&title=#{CGI::escape(item.title)}&summary=#{CGI::escape(item.description)}") do
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
    html += '<li>'
    html += link_to("http://pinterest.com/pin/create/button/?url=#{CGI::escape(repository_item_url(item))}&media=#{CGI::escape(item.derivative_image_url(512).to_s)}&description=#{CGI::escape(item.title)}") do
      raw('<i class="fa fa-pinterest-square"></i> Pinterest')
    end
    html += '</li>'

    html += '</ul>'
    html += '</div>'
    raw(html)
  end

  ##
  # @param item Repository::Item
  # @param size integer One of DerivativeManagement::STATIC_IMAGE_SIZES
  #
  def thumbnail_tag(item, size)
    return unless item
    html = "<div class=\"kq-thumbnail\">"
    thumb_url = item.derivative_image_url(size)
    if thumb_url
      html += image_tag(thumb_url, alt: 'Thumbnail image')
    else
      html += self.icon_for(item)
    end
    html += '</div>'
    raw(html)
  end

  ##
  # @param describable Describable
  # @param options :full_label_info boolean
  #
  def triples_to_dl(describable, options = {})
    exclude_uris = (Repository::Fedora::MANAGED_PREDICATES +
        [Kumquat::Application::NAMESPACE_URI])

    # process triples into an array of hashes, collapsing identical subjects
    triples = []
    describable.rdf_graph.each_statement do |statement|
      # assemble a label for the predicate
      if options[:full_label_info]
        prefix = statement.predicate.prefix
        if prefix
          label = "<span class=\"kq-predicate-uri\">#{prefix}:</span>"\
          "<span class=\"kq-predicate-uri-lpc\">#{statement.predicate.term}</span>"
        else
          label = "<span class=\"kq-predicate-uri-lpc\">#{statement.predicate.to_s}</span>"
        end
        readable = human_label_for_uri(describable, statement.predicate.to_s)
        label = "#{readable} | #{label}" if readable
      else
        label = human_label_for_uri(describable, statement.predicate.to_s)
        unless label # if there is no label, try to use "prefix:term" format
          prefix = statement.predicate.prefix
          if prefix
            label = "<span class=\"kq-predicate-uri\">#{prefix}:</span>"\
          "<span class=\"kq-predicate-uri-lpc\">#{statement.predicate.term}</span>"
          end
        end
        label = "<span class=\"kq-predicate-uri-lpc\">#{statement.predicate.to_s}</span>" unless label
      end
      triples << {
          predicate: statement.predicate.to_s, label: label, objects: []
      }
    end
    describable.rdf_graph.each_statement do |statement|
      # Exclude certain predicates & objects from display
      next if exclude_uris.select{ |p| statement.predicate.to_s.start_with?(p) or
          statement.object.to_s.start_with?(p) }.any?
      triple = triples.
          select{ |t2| t2[:predicate] == statement.predicate.to_s }.first
      triple[:objects] << statement.object.to_s if triple
    end

    dl = '<dl class="kq-triples">'
    triples.each do |struct|
      next unless struct[:objects].select{ |o| !o.strip.blank? }.any?
      dl += "<dt>#{struct[:label]}</dt>"
      struct[:objects].each do |object|
        if struct[:predicate].end_with?('/subject')
          components = object.strip.split(';')
          if components.length > 1
            value = '<ul>'
            value += components.map{ |c| "<li>#{c.strip}</li>" }.join
            value += '</ul>'
          else
            value = object.strip
          end
        else
          value = object.strip
        end
        dl += "<dd>#{value}</dd>"
      end
    end
    dl += '</dl>'
    raw(dl)
  end

  ##
  # @param item Repository::Item
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
      # a viewer are not mutually exclusive.
    elsif item.is_video?
      return video_player_for(item)
    end
    nil
  end

  private

  def audio_player_for(item)
    tag = "<audio controls>
      <source src=\"#{item.master_bytestream.repository_url}\"
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
    viewer_url = asset_path('/pdfjs/web/viewer.html?file=' +
        repository_item_master_bytestream_path(item))
    tag = link_to(viewer_url, target: '_blank') do
      #image_tag(item_image_path(item, size: 256))
    end
    tag += link_to('Open in PDF Viewer', viewer_url, target: '_blank',
                   class: 'btn btn-default')
    raw(tag)
  end

  def video_player_for(item)
    tag = "<video controls id=\"kq-video-player\">
      <source src=\"#{item.master_bytestream.repository_url}\"
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
    else
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
    if describable.kind_of?(Repository::Item)
      collection = describable.collection
    else
      collection = describable
    end
    label = nil
    p = DB::RDFPredicate.where(uri: uri, collection: collection.db_counterpart)
    p = DB::RDFPredicate.where(uri: uri, collection: nil) unless p.any?
    if p.any?
      label = p.first.label # try to use the collection's custom label
      label = p.first.default_label unless label # fall back to the global label
    end
    label
  end

end
