class Triple

  # the subject is implicitly the owning object, e.g. an Item
  attr_accessor :object
  attr_accessor :predicate

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

end
