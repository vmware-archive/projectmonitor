require 'spec_helper'

describe TwitterSearchesController do
  before do
    controller.send("current_user=",users(:valid_edward))
  end

  it "should respond to new" do
    get :new
    response.should be_success
  end

  it "should respond to create" do
    old_count = TwitterSearch.count
    post :create, :twitter_search => {}
    TwitterSearch.count.should == old_count

    post :create, :twitter_search => {:search_term=>'foo'}
    TwitterSearch.count.should == old_count + 1

    response.should redirect_to(messages_path)
  end

  it "should respond to edit" do
    get :edit, :id => TwitterSearch.create(:search_term => "foo")
    response.should be_success
  end

  it "should respond to update" do
    put :update, :id => TwitterSearch.create(:search_term => "foo"), :twitter_search => { }
    response.should redirect_to(messages_path)
  end

  it "should respond to destroy" do
    twitter_search = TwitterSearch.create(:search_term => "foo")
    lambda {
      delete :destroy, :id => twitter_search
    }.should change{ TwitterSearch.count }.by(-1)

    response.should redirect_to(messages_path)
  end

  describe "load_tweet" do
    let(:tweet) { TwitterSearch.create(:search_term => "nyc") }
    context "when the message is active" do
      it "should render the message partial" do
        get :load_tweet, :twitter_search_id => tweet.id
        response.should render_template("dashboards/_twitter_search")
        response.should be_success
      end
    end
  end
end
