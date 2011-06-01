class Explorer
  attr_accessor :source_link, :path_hash, :type, :database_path
  
  #intializes the explorer
  def initialize(link)
    @source_link = "[[" + link.gsub(' ', '_') + "]]"
    @path_hash = Hash.new
    type = nil
    @database_path = nil
  end

  def insert_link_update_path_hash(current_link, next_link)
    path_hash[current_link] = Array.new
    path_hash[current_link][0] = 0
    path_hash[current_link][1] = next_link.clone
    path_hash.each_pair do |key,value|       
      path_hash[key][0] = path_hash[key][0] + 1
    end
  end
  
  def save_to_db
    path_hash.each_pair do |key,value|
      link = Link.new
      link[:link_name] = key
      link[:type] = @type
      link[:distance] = value[0]
      link[:next_link] = value[1]
      link.save
    end
  end
    
  def update_hash_from_db(link_in_database)
    path_hash.each_pair do |key,value|
      path_hash[key][0] = path_hash[key][0] + link_in_database.distance
    end
  end

  #for the given source_link it starts to follow first links in each page until it reaches philosophy 
  #or a cycle is detected or there is a dead end
  def explore    
    current_link = @source_link
    while(current_link.downcase != "[[philosophy]]")
      link_in_database = Link.first(:link_name => current_link)      
      #If already in database then break the loop.
      if !link_in_database.nil?
        update_hash_from_db(link_in_database)
        break;
      end
                
      #if link already encountered then its a cycle.      
      if !path_hash[current_link].nil?
        @type = "cycle"
        break;
      end      
      #Get the page and its contents.
      page = Wikipedia.find(current_link.gsub(/\[/,'').gsub(/\]/,''))
      if page.nil?
        @type = "dead-end"
        break;
      end      
      content = page.content
      #Get the first link from the content.
      next_link = get_first_link(content)
      if next_link.nil?
        @type = "dead-end"
        break;
      end
      
      insert_link_update_path_hash(current_link, next_link)
      current_link = next_link
      next_link = nil
    end #end while

    #If type is nil then it succesfully found philosophy.
    if @type.nil?
      @type = "philosophy"
    end
    
    save_to_db
    
    if !link_in_database.nil?
      get_database_path(link_in_database)
      @type = @database_path.first.type
    end
  end #end explore

  def get_database_path(link_in_database)
      @database_path = Array.new
      i = 0
      while !link_in_database.nil?
        @database_path[i] = link_in_database
        i = i + 1
        link_in_database = Link.first(:link_name => link_in_database.next_link)
        #incase of cycles then break
        if @database_path.include? link_in_database
          break;
        end
      end
  end
  
  #For the given page_content it gets the first link. 
  def get_first_link(content)
    #Remove curly braces
    while content =~ /\{\{[^\{\\}]+?\}\}/
	    content.gsub!(/\{\{[^\{\}]+?\}\}/,'')
    end
    #remove info box
    content.sub!(/^\{\|[^\{\}]+?\n\|\}\n/,'')
    #remove anything in parens
    #content.gsub!(/\(.*\)/,'')
    content.gsub!(/(\(.*\))(?=^(?:(?!\[\])))/,'')
    #remove bold and italicized text
    content.gsub!(/'''''(.+?)'''''/,'')
    #remove italic text
    content.gsub!(/''(.+?)''/,'')
    #remove images and file links
    content.gsub!(/\[\[Image:.*?\]\]/,'')
    content.gsub!(/\[\[File:.*?\]\]/,'')
    content.gsub!(/\[\[image:.*?\]\]/,'')
    content.gsub!(/\[\[file:.*?\]\]/,'')
    #gets the first link
    content = content.slice(/\[\[.*?\]\]/)
    #replaces spaces with underscores (for correct resolving of links)
    content.gsub!(" ",'_')
    #removes the trailing description (for correct resolving of links)
    content = content.gsub(/\|.*?\]\]/,']]')
    return content
  end
  
end
