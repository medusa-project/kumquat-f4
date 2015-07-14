class SearchController < WebsiteController

  ##
  # Responds to GET /search
  #
  def index
    @predicates_for_select = RDFPredicate.order(:label).
        map{ |p| [ p.label, p.solr_field ] }.uniq
    @predicates_for_select.unshift([ 'Any Field', Solr::Fields::SEARCH_ALL ])

    @collections = Repository::Collection.all
  end

  ##
  # Responds to POST /search. Translates the input from the advanced search
  # form into a query string compatible with ItemsController.index, and
  # 302-redirects to it.
  #
  def search
    where_clauses = []

    # fields
    if params[:fields].any?
      params[:fields].each_with_index do |field, index|
        if params[:terms].length > index and !params[:terms][index].blank?
          where_clauses << "#{field}:#{params[:terms][index]}"
        end
      end
    end

    # collections
    keys = []
    if params[:keys].any?
      keys = params[:keys].select{ |k| !k.blank? }
    end
    if keys.any? and keys.length < Repository::Collection.all.length
      where_clauses << "#{Solr::Fields::COLLECTION_KEY}:+(#{keys.join(' ')})"
    end

    redirect_to repository_items_path(q: where_clauses.join(' AND '))
  end

end