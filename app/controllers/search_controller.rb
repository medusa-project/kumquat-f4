class SearchController < WebsiteController

  def index
    @predicates_for_select = DB::RDFPredicate.order(:label).
        map{ |p| [p.label, p.solr_field] }.uniq
  end

end