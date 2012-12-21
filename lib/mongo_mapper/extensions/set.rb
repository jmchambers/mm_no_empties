# encoding: UTF-8
require 'set'

module MongoMapper
  module Extensions
    module Set
      
      extend ActiveSupport::Concern
      
      module ClassMethods
          
        def to_mongo(value, options = {})
          recursive = options[:recursive]
          v = value.to_a
          v = v.to_mongo(options) if recursive
          v
        end
  
        def from_mongo(value)
          (value || []).to_set
        end
        
      end
      
      def to_mongo(options = {})
        self.class.to_mongo(self, options)
      end
        
    end
  end
end

class Set
  include MongoMapper::Extensions::Set
end