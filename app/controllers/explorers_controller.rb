class ExplorersController < ApplicationController
  def index
    if !params[:Wikipedia_Title].nil?
      @explorer = Explorer.new(params[:Wikipedia_Title])
      @explorer.explore
    end
  end
  def random
      @explorer = Explorer.new(Wikipedia.get_random_article.title)
      @explorer.explore
      render "index"
  end
end
