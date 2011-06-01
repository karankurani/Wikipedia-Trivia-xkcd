class LinksController < ApplicationController
  def index
    unless params[:link_distance].nil?
      @links = Link.where( :distance => params[:link_distance].to_i ).all
    end
  end
end
