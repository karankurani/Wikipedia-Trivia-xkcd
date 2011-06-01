class ExplorersController < ApplicationController
  def index
    if (!params[:Wikipedia_Title].blank?)
      @message = ""
      @explorer = Explorer.new(params[:Wikipedia_Title])
      @explorer.explore
    else
      @message = "Please enter the name of any article on wikipedia."
    end
  end
  def random
      @explorer = Explorer.new(Wikipedia.get_random_article.title)
      @explorer.explore
      render "index"
  end
end
