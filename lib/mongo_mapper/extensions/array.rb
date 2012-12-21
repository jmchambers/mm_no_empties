# encoding: UTF-8
module MongoMapper
  module Extensions
    module Array
      
      extend ActiveSupport::Concern
      
      module ClassMethods
      
        def to_mongo(value, options = {})
          stringify_bson = options[:stringify_bson]
          recursive      = options[:recursive]

          value = value.clone if recursive
          value = value.respond_to?(:lines) ? value.lines : value
          value = value.to_a
          value.map! do |v|
            
            case v
            when Document, EmbeddedDocument, Hash, Array, Set
              v = v.to_mongo(options) if v and recursive
            when BSON::ObjectId, BSON::Binary
              v = v.to_s if stringify_bson
            end
            
            v
            
          end
          value
        end
  
        def from_mongo(value)
          value || []
        end
      
      end
      
      def to_mongo(options = {})
        self.class.to_mongo(self, options)
      end
      
    end
  end
end

class Array
  include MongoMapper::Extensions::Array
end