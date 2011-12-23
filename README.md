
mm_no_empties
============

Models that use this plugin do not persist empty Arrays, Hashes or Sets

Requirements
============

- Ruby 1.9
- MongoMapper 0.10.1 or greater

Installation
=======

Add this to your Gemfile if using Bundler: `gem 'mm_no_empties'`

Or install the gem from the command line: `gem install mm_no_empties`

Usage
=======

Use the MongoMapper `plugin` method to add MmNoEmpties to your model, for example:

```
class Group
  include MongoMapper::Document
  plugin  MmNoEmpties
  
  many :people, :class_name => 'Person'
end
```

Copyright (c) 2011 PeepAll Ltd, released under the MIT license