# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pvc/version"

Gem::Specification.new do |s|
  s.name        = "pvc"
  s.version     = PVC::VERSION
  s.authors     = ["Chris Berkhout"]
  s.email       = ["chrisberkhout@gmail.com"]
  s.homepage    = "http://chrisberkhout.com"
  s.summary     = %q{Easy piping between processes}

  s.rubyforge_project = "pvc"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  
  s.required_ruby_version = '>= 1.9.0'
end
