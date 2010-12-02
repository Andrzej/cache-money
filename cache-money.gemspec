# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cache-money/version"

Gem::Specification.new do |s|
  s.name        = "cache-money"
  s.version     = Cache::Money::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["nkallen"]
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/cache-money"
  s.summary     = ""
  s.description = ""

  s.rubyforge_project = "cache-money"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
