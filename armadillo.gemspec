Gem::Specification.new do |s|
  s.name = "armadillo"
  s.version = "0.0.2"
  s.summary = "Template inheritance with ERB templates"
  s.description = "A small library for Django-like template inheritance adapted for ERB"
  s.authors = ["Sebastian Borrazas"]
  s.email = ["seba.borrazas@gmail.com"]
  s.homepage = "http://github.com/sborrazas/armadillo"
  s.license = "MIT"

  s.files = Dir[
    "LICENSE",
    "README.md",
    "Rakefile",
    "lib/**/*.rb",
    "*.gemspec",
    "spec/*.*"
  ]

  s.require_paths = ["lib"]

  s.add_dependency "tilt"

end
