class SourcesController < ApplicationController
  def index
    @sources = Source.all
  end
  def edit
    @name = params[:name]
    @source = Source.find_by(name: @name)
    if @source.nil?
      render '404'
    end
  end
end
