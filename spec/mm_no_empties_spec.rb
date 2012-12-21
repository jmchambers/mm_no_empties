require File.expand_path('../../lib/mm_no_empties', __FILE__)
require 'pry'

describe MmNoEmpties do
  
  before(:all) do    
    class Company
      include MongoMapper::Document
      many :groups
    end
    
    class Group
      include MongoMapper::Document
      plugin  MmNoEmpties
      
      many :people, :class_name => 'Person'
      one  :owner,  :class_name => 'Person'
      belongs_to :company
      
      key  :motto,  String
      
      key  :names,  Array
      key  :counts, Hash
      key  :tags,   Set
    end
    
    class Person
      include MongoMapper::EmbeddedDocument
      plugin  MmNoEmpties
      
      key :name
      key :age
      
      belongs_to :group
    end
    
    MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
    MongoMapper.database = 'mm_no_empties_test'
    
    @person = Person.new(name: 'Jon', age: 33)
    @group  = Group.create :people => [@person]

  end
  
  it "should not include empty Arrays, Hashes and Sets in 'attributes'" do
    @group.attributes.keys.should_not include('names', 'counts', 'tags')
  end
  
  it "should not include nil values in 'attributes'" do
    @group.attributes.keys.should_not include('motto')
  end
  
  it "should not include unused many associations in attributes" do
    @group.attributes.keys.should_not include('owner', 'company_id')
  end
  
  it "should restore empty fields when loading from the database" do
    Group.first.attributes(:include_all => true).keys.should include('names', 'counts', 'tags')
  end
  
  it "should call to_mongo on array elements when recursive is true" do
    @group['an_array'] = [1, 2, [3, 4].to_set]
    @group.attributes(:recursive => true)['an_array'].should == [1, 2, [3, 4]]
  end
  
  it "should call to_mongo on set elements when recursive is true" do
    @group['a_set'] = [1, 2, [3, 4].to_set].to_set
    @group.attributes(:recursive => true)['a_set'].should == [1, 2, [3, 4]]
  end
  
  it "should call to_mongo on hash values when recursive is true" do
    @group['a_hash'] = {:a => [1, 2].to_set}
    @group.attributes(:recursive => true)['a_hash']['a'].should == [1, 2]
  end
  
  it "should convert a BSON::ObjectId to a string if stringify_bson is true" do
    @group.attributes(:stringify_bson => true)['_id'].should == @group.id.to_s
  end
  
  it "should convert a BSON::ObjectId in an embedded document to a string if stringify_bson is true" do
    @group.attributes(:stringify_bson => true)['people'].first['_id'].should == @person.id.to_s
  end
  
  it "should convert a BSON::Binary to a string if stringify_bson is true" do
    @group['a_bson_binary'] = BSON::Binary.new("foo")
    @group.attributes(:stringify_bson => true)['a_bson_binary'].should be_an_instance_of String
  end
  
  it "should convert a BSON::Binary in an embedded document to a string if stringify_bson is true" do
    @group.people.first['a_bson_binary'] = BSON::Binary.new("foo")
    @group.attributes(:stringify_bson => true)['people'].first['a_bson_binary'].should be_an_instance_of String
  end
  
  after(:all) do
    Group.delete_all
  end
  
end