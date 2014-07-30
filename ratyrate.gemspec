# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ratyrate/version"

Gem::Specification.new do |s|
  s.name        = "ratyrate"
  s.version     = Ratyrate::VERSION
  s.authors     = ["Islam Wazery"]
  s.email       = ["wazery@ubuntu.com"]
  s.homepage    = "http://github.com/wazery/ratyrate"
  s.summary     = %q{A Ruby Gem that provides the same functionality of jQuery Raty library, and adds IMDB style rating.}
  s.description = %q{A Ruby Gem that provides the same functionality of jQuery Raty library, and adds IMDB style rating.}

  s.rubyforge_project = "ratyrate"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
