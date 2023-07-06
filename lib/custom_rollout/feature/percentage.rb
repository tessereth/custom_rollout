class CustomRollout
  class Feature
    class Percentage < Feature
      attr_reader :percentage

      def percentage=(percent)
        with_update do
          @percentage = percent
        end
      end

      def serialize
        @percentage.to_s
      end

      def update_from_serialized(raw)
        @percentage = raw.to_f
      end

      def state(string)
        if self.class.within_percent(string, @percentage)
          ENABLED
        else
          DISABLED
        end
      end

      def enabled?(string)
        state(string) == ENABLED
      end
    end
  end
end
