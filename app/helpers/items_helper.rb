module ItemsHelper

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

end
