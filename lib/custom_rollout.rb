require 'zlib'
require 'custom_rollout/feature'
require 'custom_rollout/feature/percentage'
require 'custom_rollout/feature/warmup'

class CustomRollout
  VERSION = "0.0.1"

  ENABLED = :enabled
  DISABLED = :disabled
  WARMUP = :warmup
  COOLDOWN = :cooldown

  def self.percentage(key:, store:)
    CustomRollout::Feature::Percentage.new(key:, store:)
  end

  def self.warmup(key:, store:)
    CustomRollout::Feature::Warmup.new(key:, store:)
  end
end
