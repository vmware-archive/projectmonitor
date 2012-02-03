class TwitterSearchesController < ApplicationController
  before_filter :login_required

  def new
    @twitter_search = TwitterSearch.new
  end

  def edit
    @twitter_search = TwitterSearch.find(params[:id])
  end

  def create
    @twitter_search = TwitterSearch.new(params[:twitter_search])

    if @twitter_search.save
      flash[:notice] = 'Twitter Search was successfully created.'
      redirect_to(messages_path)
    else
      render :action => "new"
    end
  end

  def load_tweet
    render :partial => "dashboards/twitter_search", :locals => { :twitter_search => TwitterSearch.find_by_id(params[:twitter_search_id]) }
  end

  def update
    @twitter_search = TwitterSearch.find(params[:id])

    if @twitter_search.update_attributes(params[:twitter_search])
      flash[:notice] = 'Twitter Search was successfully updated.'
      redirect_to(messages_path)
    else
      render :action => "edit"
    end
  end

  def destroy
    @twitter_search = TwitterSearch.find(params[:id])
    @twitter_search.destroy
    flash[:notice] = 'Twitter Search was successfully destroyed.'
    redirect_to(messages_path)
  end
end
