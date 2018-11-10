module Input
  class << self
    def load(input)
      @input = input || {}
      @input.freeze
    end

    def [](key)
      @input[key]
    end
  end
end
