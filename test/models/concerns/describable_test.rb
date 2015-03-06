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

  # replace_statement

  test 'replace_statement should replace a matching statement' do
    new_subject = RDF::URI('http://example.org/')
    new_predicate = RDF::URI('http://example.net/')
    new_object = 'dogs'
    new_statement = RDF::Statement.new(new_subject, new_predicate, new_object)

    @described.replace_statement(@graph, new_statement)

    assert_equal 1, @graph.statements.count
    assert_equal 'dogs', @graph.statements.first.object.to_s
  end

end