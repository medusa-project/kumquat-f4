module ItemsHelper

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
          term_params = term.removed_from_params(params)
          clear_link = link_to(term_params, class: 'kq-clear') do
            content_tag(:i, nil, class: 'fa fa-remove')
          end
          term_html = "<span class=\"kq-selected-term\">#{term.name}</span>"
        else
          term_html = link_to(term.name, term.added_to_params(params))
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
          term_params = term.removed_from_params(params)
          clear_link = link_to(term_params, class: 'kq-clear') do
            content_tag(:i, nil, class: 'fa fa-remove')
          end
          term_html = "<span class=\"kq-selected-term\">#{term.name}</span>"
        else
          term_html = link_to(term.name, term.added_to_params(params))
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

  ##
  # @param describable Describable
  # @param options :predicates_as_uris (true or false)
  #
  def triples_to_dl(describable, options = {})
    # process triples into an array of hashes, collapsing identical subjects
    triples = describable.triples.sort.map do |t|
      {
          predicate: t.predicate,
          label: options[:predicates_as_uris] ? t.predicate : t.label,
          objects: []
      }
    end
    describable.triples.each do |t|
      triples.select{ |t2| t2[:predicate] == t.predicate }.first[:objects] << t.object
    end

    dl = '<dl>'
    triples.each do |struct|
      next if struct[:predicate].include?('http://fedora.info/definitions/')
      next if struct[:predicate].include?(Kumquat::Application::NAMESPACE_URI)
      if struct[:objects].any?
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
    elsif item.is_video?
      return video_viewer_for(item)
    end
    raw("<!-- No viewer available for media type #{item.media_type} -->\n")
  end

  private

  def audio_player_for(item)
    # TODO: write audio_player_for
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
