class UsersController < ApplicationController
  before_filter :login_required

  # render new.rhtml
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      redirect_to('/')
      flash[:notice] = "User created."
    else
      flash[:error]  = "Errors; please try again."
      render :action => 'new'
    end
  end
end
