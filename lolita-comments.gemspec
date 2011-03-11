# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lolita-comments/version"

Gem::Specification.new do |s|
  s.name        = "lolita-comments"
  s.version     = LolitaComments::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["ITHouse","Artūrs Meisters"]
  s.email       = ["support@ithouse.lv"]
  s.homepage    = "http://rubygems.org/gems/lolita-comments"
  s.summary     = %q{Comments gem for Lolita}
  s.description = %q{Fully configured comment gem for Lolita}

  s.required_rubygems_version = ">=1.3.6"
  s.rubyforge_project = "lolita-comments"

  s.add_development_dependency "bundler", ">=1.0.2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib","app"]
end
