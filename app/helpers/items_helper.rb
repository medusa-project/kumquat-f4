module ItemsHelper

  PREFIXES = { # TODO: externalize this
      dc: 'http://purl.org/dc/elements/1.1/',
      dcterms: 'http://purl.org/dc/terms/'
  }

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
          <span class=\"kq-count\">#{term.count}</span>
          #{clear_link}
        </li>"
      end
      panels += panel + '</ul></div></div>'
    end
    raw(panels)
  end

  ##
  # @param items ActiveKumquat::ResultSet
  #
  def facets_as_ul(items)
    term_limit = Kumquat::Application.kumquat_config[:facet_term_limit]
    ul = '<ul>'
    items.facet_fields.each do |facet|
      next unless facet.terms.select{ |t| t.count > 0 }.any?
      ul += "<li class=\"kq-field\">
        <span class=\"kq-field-name\">#{facet.label}</span>"
      ul += '<ul class="kq-terms">'
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
        ul += "<li class=\"kq-term\">
          <span class=\"kq-term-name\">#{term_html}</span>
          <span class=\"kq-count\">#{term.count}</span>
          #{clear_link}
        </li>"
      end
      ul += '</ul>
      </li>'
    end
    ul += '</ul>'
    raw(ul)
  end

  def is_favorite?(item)
    cookies[:favorites].split(FavoritesController::COOKIE_DELIMITER).
        select{ |f| f == item.web_id }.any?
  end

  ##
  # @param items ActiveKumquat::Entity
  # @param start integer
  # @param options Hash with available keys: :show_remove_from_favorites_button
  #
  def items_as_list(items, start, options = {})
    html = "<ol start=\"#{start + 1}\">"
    items.each do |item|
      html += '<li>'\
        '<div>'
      if item.kind_of?(Item)
        html += link_to(item, class: 'kq-thumbnail-link') do
          thumbnail_tag(item)
        end
      end
      html += '<span class="kq-title">'
      html += link_to(item.title, item)
      if options[:show_remove_from_favorites_button]
        html += ' ' + link_to(favorite_url(item), class: 'btn btn-xs btn-danger', method: 'delete') do
          raw('<i class="fa fa-heart-o"></i> Remove')
        end
      end
      if item.kind_of?(Item) and item.children.any?
        html += '<span class="label label-info kq-page-count">'
        html += pluralize(item.children.length, 'page')
        html += '</span>'
      end
      html += '</span>'
      html += '<br>'
      html += '<span class="kq-description">'
      html += truncate(item.description.to_s, length: 400)
      html += '</span>'
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
    cookies[:favorites].split(FavoritesController::COOKIE_DELIMITER).length
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

  def thumbnail_tag(item)
    return unless item
    html = "<div class=\"kq-thumbnail\">"
    thumb_path = item.image_path
    if File.exist?(thumb_path)
      html += image_tag(item.public_image_path(root_path))
    else
      icon = 'fa-cube'
      if item.is_audio?
        icon = 'fa-volume-up'
      elsif item.is_image?
        icon = 'fa-picture-o'
      elsif item.is_pdf? or item.is_text?
        icon = 'fa-file-text-o'
      elsif item.is_video?
        icon = 'fa-film'
      elsif item.kind_of?(Collection)
        icon = 'fa-cubes'
      end
      html += "<i class=\"fa #{icon}\"></i>"
    end
    html += '</div>'
    raw(html)
  end

  ##
  # @param describable Describable
  #
  def triples_to_dl(describable)
    # Predicates whose URIs start with the following will be excluded from
    # display. This is more or less all repository-managed administrative
    # metadata that nobody cares about.
    exclude_predicates = [
        'http://fedora.info/definitions/',
        'http://www.jcp.org/jcr',
        'http://www.w3.org/1999/02/22-rdf-syntax-ns',
        'http://www.w3.org/2000/01/rdf-schema',
        'http://www.w3.org/ns/ldp'
    ]
    # process triples into an array of hashes, collapsing identical subjects
    triples = []
    describable.rdf_graph.each_statement do |statement|
      # exclude certain predicates from display
      skip_statement = false
      exclude_predicates.each do |ex_p|
        if statement.predicate.to_s.start_with?(ex_p)
          skip_statement = true
          break
        end
      end
      next if skip_statement

      # see if we can replace the full predicate URI with a prefix
      glue = statement.predicate.to_s.include?('#') ? '#' : '/'
      parts = statement.predicate.to_s.split(glue)
      last = parts.pop
      prefix = parts.join(glue) + glue
      if PREFIXES.values.include?(prefix)
        prefix = PREFIXES.key(prefix).to_s + ':'
      end
      triples << {
          predicate: statement.predicate.to_s,
          label: "<span class=\"kq-predicate-uri\">#{prefix}</span>"\
          "<span class=\"kq-predicate-uri-lpc\">#{last}</span>",
          objects: []
      }
    end
    describable.rdf_graph.each_statement do |statement|
      triple = triples.
          select{ |t2| t2[:predicate] == statement.predicate.to_s }.first
      triple[:objects] << statement.object.to_s if triple
    end

    dl = '<dl class="kq-triples">'
    triples.each do |struct|
      next if struct[:predicate].include?('http://fedora.info/definitions/')
      next if struct[:predicate].include?(Kumquat::Application::NAMESPACE_URI)
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
  # @param item Item
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
      return video_viewer_for(item)
    end
    nil
  end

  private

  def audio_player_for(item)
    tag = "<audio controls>
      <source src=\"#{item_master_bytestream_url(item)}\"
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
        item_master_bytestream_path(item))
    tag = link_to(viewer_url, target: '_blank') do
      #image_tag(item_image_path(item, size: 256))
    end
    tag += link_to('Open in PDF Viewer', viewer_url, target: '_blank',
                   class: 'btn btn-default')
    raw(tag)
  end

  def video_viewer_for(item)
    # TODO: write video_viewer_for
  end

end
