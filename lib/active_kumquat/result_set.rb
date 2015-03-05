module ActiveKumquat

  class ResultSet
    include Enumerable

    ##
    # The total length of the result set, if the result set is paged; otherwise
    # the same as length().
    #
    attr_accessor :total_length

    def initialize
      @array = []
      @total_length = 0
    end

    def each(&block)
      @array.each{ |member| block.call(member) }
    end

    def method_missing(name, *args, &block)
      @array.send(name, *args, &block)
    end

    def respond_to_missing?(method_name, include_private = true)
      @array.respond_to?(method_name, include_private)
    end

  end

end
