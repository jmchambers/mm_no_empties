require 'mongo_mapper'
require "mm_no_empties/version"
require 'mongo_mapper/plugins/keys/key'

#modified versions of to_mongo that check nested values
require_relative 'mongo_mapper/extensions/array'
require_relative 'mongo_mapper/extensions/hash'
require_relative 'mongo_mapper/extensions/set'

module MmNoEmpties
  
  extend ActiveSupport::Concern
  
  module ClassMethods
    
    def set(*args)
      criteria, updates, options = criteria_and_keys_from_args(args)
      
      unset_cmd = {}
      
      updates.each do |key, value|
        updates[key]   = keys[key.to_s].set(value) if key?(key)
        unset_cmd[key] = 1 unless updates[key].present?
      end

      set_attr = updates.except(*unset_cmd.keys)
  
      update_cmd = {}
      update_cmd['$set']   = set_attr  if set_attr.present?
      update_cmd['$unset'] = unset_cmd if unset_cmd.present?
  
      if options
        collection.update(criteria, update_cmd, options.merge(:multi => true))
      else
        collection.update(criteria, update_cmd, :multi => true)
      end
  
    end
    
  end
      
  def attributes(options = {})

    include_all     = options[:include_all]
    stringify_bson  = options[:stringify_bson]
    recursive       = options[:recursive]
    
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
        v = key.set(self[key.name])
        case v
        when MongoMapper::Document, MongoMapper::EmbeddedDocument, Hash, Array, Set
          v = v.to_mongo(options) if v and recursive
        when BSON::ObjectId, BSON::Binary
          v = v.to_s if stringify_bson
        end
        attrs[name] = v   
      end

      embedded_associations.each do |association|
        if documents = instance_variable_get(association.ivar)
          
          val = if association.is_a?(MongoMapper::Plugins::Associations::OneAssociation)
            documents.to_mongo(options)
          else
            documents.map { |document| document.to_mongo(options) }
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


