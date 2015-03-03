module Contentdm

  ##
  # Abstract class extended by DCElement and LocalElement.
  #
  class Element

    attr_accessor :name
    attr_accessor :value

    def initialize(params = {})
      params.each do |k, v|
        if respond_to?("#{k}=")
          send "#{k}=", v
        else
          instance_variable_set "@#{k}", v
        end
      end
    end

    def namespace_prefix
      raise 'Subclasses must override namespace_prefix()'
    end

    def namespace_uri
      raise 'Subclasses must override namespace_uri()'
    end

    def value=(value_)
      @value = value_.strip.squeeze(' ').gsub('\t', '')
    end

  end

end
