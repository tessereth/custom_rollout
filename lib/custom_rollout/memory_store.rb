# A feature store for testing purposes. In reality you would use redis or
# similar.
class CustomRollout
  class MemoryStore
    def initialize
      @data = {}
    end

    def set(key, value)
      @data[key] = value
    end

    def get(key)
      @data[key]
    end
  end
end
