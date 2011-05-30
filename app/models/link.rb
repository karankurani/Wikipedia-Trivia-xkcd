class Link
  include MongoMapper::Document
  
  key :link, String
  key :type, String
  key :distance, Integer
  key :next_link, String
end
