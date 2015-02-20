module ItemsHelper

  ##
  # @param item Item
  #
  def triples_to_dl(item)
    # collect triples into a hash of object (value) arrays keyed by predicate
    triples = {}
    item.triples.each{ |t| triples[t.predicate] = [] }
    triples.keys.each do |k|
      triples[k] = item.triples.select{ |t2| t2.predicate == k }.map{ |t2| t2.object }
    end

    dl = '<dl>'
    triples.each do |predicate, objects|
      next if predicate.include?('http://fedora.info/definitions/')
      if objects.any?
        term = Triple::LABELS.keys.include?(predicate) ?
            Triple::LABELS[predicate] : predicate
        dl += "<dt>#{term}</dt>"
        objects.each do |object|
          dl += "<dd>#{object}</dd>"
        end
      end
    end
    dl += '</dl>'
    raw(dl)
  end

end
