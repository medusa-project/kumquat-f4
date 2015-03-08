class Triple

  include Comparable

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
    # sort alphabetically by label, with label-less triples last.
    return -1 if self.label < other.label and !self.label.include?('://')
    return 0 if self.label == other.label
    1
  end

  def label
    I18n.t('uri_' + self.predicate.gsub('://', '_').tr(':/.', '_'),
           default: self.predicate)
  end

  def to_s
    self.object
  end

end
