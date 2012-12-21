# encoding: UTF-8
module MongoMapper
  module Extensions
    module Hash
      
      extend ActiveSupport::Concern

      module ClassMethods
      
        def to_mongo(value, options = {})
          stringify_bson = options[:stringify_bson]
          recursive      = options[:recursive]

          value = value.clone if recursive
          hash  = value.to_hash
          hash.each do |k,v|
            
            case v
            when Document, EmbeddedDocument, Hash, Array, Set
              v = v.to_mongo(options) if v and recursive
            when BSON::ObjectId, BSON::Binary
              v = v.to_s if stringify_bson
            end

            hash[k] = v
            
          end
          hash
        end
        
        def from_mongo(value)
          HashWithIndifferentAccess.new(value || {})
        end
        
      end
      
      def to_mongo(options = {})
        self.class.to_mongo(self, options)
      end
      
    end
  end
end

class Hash
  include MongoMapper::Extensions::Hash
end