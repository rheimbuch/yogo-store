# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "yogo-store/version"

Gem::Specification.new do |s|
  s.name        = "yogo-store"
  s.version     = Yogo::Store::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "yogo-store"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("git_store", "~> 0.3.1")
  s.add_dependency("grit", "~> 2.4.1")
  s.add_dependency("fastercsv" ">= 1.5.4") if RUBY_VERSION < "1.9"
  s.add_dependency("sequel", "~> 3.21.0")
  s.add_dependency("sqlite3", "~> 1.3.3")
  s.add_dependency("rufus-tokyo", "~> 1.0.7")
  s.add_dependency("ffi", "~> 1.0.7")
  s.add_dependency("configatron", "~> 2.7.0")
  s.add_dependency("activesupport", ">= 3.0.0")
  s.add_dependency("i18n", "~> 0.5.0")
end
