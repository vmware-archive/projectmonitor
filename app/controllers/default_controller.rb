class DefaultController < ApplicationController
  def show
    respond_to do |format|
      format.html {}
      format.iphone {redirect_to pulse_path}
    end
  end
end
