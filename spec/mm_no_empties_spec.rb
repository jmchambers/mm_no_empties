require File.expand_path('../../lib/mm_no_empties', __FILE__)

describe MmNoEmpties do
  
  before(:all) do    
    class Group
      include MongoMapper::Document
      plugin  MmNoEmpties
      
      many :people, :class_name => 'Person'
      
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
    
    @group  = Group.create
    @person = Person.new(name: 'Jon', age: 33)
  end
  
  it "should not include empty Arrays, Hashes and Sets in 'attributes'" do
    @group.attributes.keys.should_not include('names', 'counts', 'tags')
  end
  
  it "should not include unused many associations in attributes" do
    @group.attributes.keys.should_not include('people')
  end
  
  it "should restore empty fields when loading from the database" do
    Group.first.attributes(:include_all).keys.should include('names', 'counts', 'tags')
  end
  
  after(:all) do
    Group.delete_all
  end
  
end