module Contentdm

  class Entity

    attr_accessor :elements # array of Elements

    def initialize(source_path)
      @source_path = source_path
      self.elements = []
    end

  end

end
