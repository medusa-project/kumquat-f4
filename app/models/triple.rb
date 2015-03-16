class Triple

  include Comparable

  PREFIXES = {
      dc: 'http://purl.org/dc/elements/1.1/',
      dcterms: 'http://purl.org/dc/terms/'
  }

  # the subject is implicitly the owning object, e.g. an Item
  attr_accessor :object
  attr_accessor :predicate
  attr_accessor :type

  alias_method :value, :object
  alias_method :name, :predicate

  def initialize(params = {})
    params.each do |k, v|
      if respond_to?("#{k}=")
        send "#{k}=", v
      else
        instance_variable_set "@#{k}", v
      end
    end
  end

  def <=>(other)
    # sort alphabetically by last path component
    return -1 if self.last_path_component < other.last_path_component
    return 0 if self.last_path_component == other.last_path_component
    1
  end

  def last_path_component
    glue = self.predicate.include?('#') ? '#' : '/'
    parts = self.predicate.split(glue)
    parts.pop
  end

  def to_s
    self.object
  end

end
