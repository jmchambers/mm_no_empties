require 'mongo_mapper'
require "mm_no_empties/version"
require 'mongo_mapper/plugins/keys/key'

module MmNoEmpties
  
  extend ActiveSupport::Concern
      
  def attributes(include_all = false)
    
    HashWithIndifferentAccess.new.tap do |attrs|
      persistable_keys = if include_all
        keys
      else
        keys.select do |name, key|
          val = self[key.name]
          #key.type == ObjectId or   # this is in the original :attributes implementation, but is seems safe to remove it as 'belongs_to: nil' if it's missing
          not (val.nil? or (val.respond_to?(:empty?) and val.empty?))
        end
      end
      
      persistable_keys.each do |name, key|
        value = key.set(self[key.name])
        attrs[name] = value
      end

      embedded_associations.each do |association|
        if documents = instance_variable_get(association.ivar)
          
          val = if association.is_a?(MongoMapper::Plugins::Associations::OneAssociation)
            documents.to_mongo
          else
            documents.map { |document| document.to_mongo }
          end
            
          if include_all
            attrs[association.name] = val
          else
            attrs[association.name] = val unless val.nil? or (val.is_a?(Array) and val.empty?)
          end
          
        end
      end
    end
  end
  alias :to_mongo :attributes

  
end
