class CustomRollout
  class Feature
    class Warmup < Feature
      class SequencingError < StandardError; end

      attr_reader :warmup_percentage, :active_percentage, :cooldown_percentage

      def warmup_percentage=(percent)
        raise ArgumentError unless 0 <= percent && percent <= 100
        raise SequencingError.new("Cannot warmup while cooling down") unless @cooldown_percentage == 0
        raise ArgumentError.new("Tried to warmup more than is available") unless percent + @active_percentage <= 100

        with_update do
          @warmup_percentage = percent.to_f
        end
      end

      def enable_warmed
        raise SequencingError.new("Currently not warming up") unless @warmup_percentage > 0
        with_update do
          @active_percentage += @warmup_percentage
          @warmup_percentage = 0.0
        end
      end

      def cooldown_percentage=(percent)
        raise ArgumentError unless 0 <= percent && percent <= 100
        raise SequencingError.new("Cannot cool down while warming up") unless @warmup_percentage == 0
        raise ArgumentError.new("Tried to cool down more than is available") unless percent <= @active_percentage

        with_update do
          @cooldown_percentage = percent.to_f
        end
      end

      def disable_cooled
        raise SequencingError.new("Currently not cooling down") unless @cooldown_percentage > 0
        with_update do
          @active_percentage -= @cooldown_percentage
          @cooldown_percentage = 0.0
        end
      end

      def serialize
        [@warmup_percentage, @active_percentage, @cooldown_percentage].join("|")
      end

      def update_from_serialized(raw)
        fields = raw.to_s.split("|")
        @warmup_percentage = fields[0].to_f
        @active_percentage = fields[1].to_f
        @cooldown_percentage = fields[2].to_f
      end

      def state(string)
        if self.class.within_percent(string, @active_percentage - @cooldown_percentage)
          ENABLED
        elsif self.class.within_percent(string, @active_percentage)
          COOLDOWN
        elsif self.class.within_percent(string, @active_percentage + @warmup_percentage)
          WARMUP
        else
          DISABLED
        end
      end

      def percentages
        {
          ENABLED => @active_percentage - @cooldown_percentage,
          DISABLED => 100 - @active_percentage - @warmup_percentage,
          WARMUP => @warmup_percentage,
          COOLDOWN => @cooldown_percentage,
        }
      end
    end
  end
end
