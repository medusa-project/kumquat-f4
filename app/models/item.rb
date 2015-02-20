class Item

  extend ActiveModel::Naming

  attr_accessor :triples
  attr_accessor :fedora_uri
  attr_accessor :uuid

  def initialize(params = {})
    self.triples = []
    params.each do |k, v|
      if respond_to?("#{k}=")
        send "#{k}=", v
      else
        instance_variable_set "@#{k}", v
      end
    end
  end

  def persisted?
    true
  end

  def title
    t = self.triples.select do |e|
      e.predicate.include?('http://purl.org/dc/elements/1.1/title')
    end
    t.first ? t.first.value : 'Untitled'
  end

  def to_model
    self
  end

  def to_param
    self.uuid
  end

end
