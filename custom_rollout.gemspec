Gem::Specification.new do |s|
  s.name        = "custom_rollout"
  s.version     = CustomRollout::VERSION
  s.summary     = "Like feature flags but for complex phased rollouts"
  s.description = "Like feature flags but for complex phased rollouts"
  s.authors     = ["Tessa Bradbury"]
  s.email       = "tessereth@yahoo.com.au"
  s.files       = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.homepage    = "https://github.com/tessereth/custom_rollout"
  s.license     = "MIT"
end
