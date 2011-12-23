# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mm_no_empties/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jonathan Chambers"]
  gem.email         = ["j.chambers@gmx.net"]
  gem.description   = %q{MongoMapper plugin that prevents any fields responding to empty? from being persisted if empty}
  gem.summary       = %q{plugin to stop MM persisting empties}
  gem.homepage      = 'https://github.com/jmchambers/mm_no_empties'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "mm_no_empties"
  gem.require_paths = ['lib']
  gem.version       = MmNoEmpties::VERSION
  gem.license       = 'MIT'
  
  gem.add_development_dependency "rspec", "~> 2.7"
  gem.add_development_dependency "bson_ext", "~> 1.5.0"
  gem.add_dependency "mongo_mapper", "~> 0.10.1"
  
end