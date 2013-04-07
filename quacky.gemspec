Gem::Specification.new do |s|
  s.name       = "quacky"
  s.version    = File.read "VERSION"
  s.summary    = "Ensure your test doubles quack like the real thing."
  s.email      = ["moonmaster9000@gmail.com", "ben@mossity.com"]
  s.homepage   = "https://github.com/benmoss/quacky"
  s.authors    = ["Matt Parker", "Ben Moss"]
  s.license    = "MIT"

  s.files      = Dir["lib/**/*"] << "VERSION" << "LICENSE"
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "activesupport", "~> 3.2.5"
  s.add_development_dependency "rspec"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "specdown"
  s.add_development_dependency "rake"
  s.add_development_dependency "coveralls"
end
