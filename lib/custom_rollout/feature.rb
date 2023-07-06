class CustomRollout
  class Feature
    RAND_BASE = (2**32 - 1) / 100.0

    attr_reader :key, :store, :percentage

    def initialize(key:, store:)
      @key = key
      @store = store
      load
    end

    def with_update
      yield
      save
    end

    def save
      @store.set(storage_key, serialize)
    end

    def storage_key
      "custom-rollout:#{key}"
    end

    def serialize
      # Should be implemented by sub-classes
      raise NotImplementedError
    end

    def load
      raw = @store.get(storage_key)
      update_from_serialized(raw)
    end

    def update_from_serialized(raw)
      # Should be implemented by sub-classes
      raise NotImplementedError
    end

    def self.within_percent(string, percent)
      Zlib.crc32(string.to_s) < RAND_BASE * percent
    end
  end
end
