class RevisionsController < ApplicationController
  def show
    render :text => File.read(File.join(Rails.root, 'REVISION'))
  end
end
