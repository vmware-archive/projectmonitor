class MessagesController < ApplicationController
  before_filter :login_required

  def index
    @messages = Message.active
    @twitter_searches = TwitterSearch.all
  end

  def new
    @message = Message.new
  end

  def edit
    @message = Message.find(params[:id])
  end

  def create
    @message = Message.new(params[:message])

    if @message.save
      flash[:notice] = 'Message was successfully created.'
      redirect_to(messages_path)
    else
      render :action => "new"
    end
  end

  def update
    @message = Message.find(params[:id])

    if @message.update_attributes(params[:message])
      flash[:notice] = 'Message was successfully updated.'
      redirect_to(messages_path)
    else
      render :action => "edit"
    end
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    flash[:notice] = 'Message was successfully destroyed.'
    redirect_to(messages_path)
  end
end
