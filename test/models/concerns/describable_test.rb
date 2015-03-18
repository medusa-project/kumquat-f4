require 'test_helper'

class DescribableTest < ActiveSupport::TestCase

  class Described
    include Describable
  end

  setup do
    @graph = RDF::Graph.new
    @subject = RDF::URI('http://example.org/')
    @predicate = RDF::URI('http://example.net/')
    @object = 'cats'
    @statement = RDF::Statement.new(@subject, @predicate, @object)
    @described = Described.new
  end

  # delete_predicate

  test 'delete_predicate should delete all statements matching a given predicate' do
    @graph << RDF::Statement.new(@subject, @predicate, 'cats')
    @graph << RDF::Statement.new(@subject, @predicate, 'dogs')
    @graph << RDF::Statement.new(@subject, RDF::URI('http://example.com/'), 'chickens')
    @described.delete_predicate(@graph, @predicate)
    assert_equal 1, @graph.statements.count
    assert_equal 'chickens', @graph.statements.first.object.to_s
  end

end
