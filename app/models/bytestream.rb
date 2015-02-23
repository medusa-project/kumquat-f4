class Bytestream

  attr_accessor :fedora_uri
  attr_accessor :media_type

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
