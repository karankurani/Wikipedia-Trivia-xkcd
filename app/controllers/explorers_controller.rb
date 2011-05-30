class ExplorersController < ApplicationController
  def index
    if !params[:Wikipedia_Title].nil?
      @explorer = Explorer.new(params[:Wikipedia_Title])
      @explorer.explore
    end
  end
end
