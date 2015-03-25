class SearchController < WebsiteController

  ##
  # Responds to GET /search
  #
  def index
    @predicates_for_select = DB::RDFPredicate.order(:label).
        map{ |p| [ p.label, p.solr_field ] }.uniq
    @predicates_for_select.unshift([ 'Any Field', 'kq_searchall' ])
  end

  ##
  # Responds to POST /search. Translates the input from the advanced search
  # form into a query string compatible with ItemsController.index, and
  # 302-redirects to it.
  #
  def search
    # field search
    where_clauses = []
    if params[:fields].any?
      params[:fields].each_with_index do |field, index|
        if params[:terms].length > index and !params[:terms][index].blank?
          where_clauses << "#{field}:#{params[:terms][index]}"
        end
      end
    end

    #render text: YAML::dump(params.inspect)
    redirect_to repository_items_path(q: where_clauses.join(' AND '))
  end

end