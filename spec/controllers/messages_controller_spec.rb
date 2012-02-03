require 'spec_helper'

describe MessagesController do
  context "with no logged in user" do
    describe "index" do
      it "should redirect to the login page" do
        get :index
        response.should redirect_to(login_path)
      end
    end

    describe "load_project_with_status" do
      let(:message) { messages(:company_meeting) }
      context "when the message is active" do
        it "should render the message partial" do
          get :load_message, :message_id => message.id
          response.should render_template("dashboards/_message")
          response.should be_success
        end
      end
      context "when the message is not active" do
        before { message.update_attributes!({:expires_at => 1.day.ago}) }
        it "should return status 204" do
          get :load_message, :message_id => message.id
          response.should_not render_template("dashboards/_message")
          response.should be_success
          response.blank.should be_true
          response.body.length == 1
        end
      end
    end
   end

  context "with a logged in user" do
    before(:each) do
      controller.send("current_user=",users(:valid_edward))
    end

    describe "#index" do
      it "should respond to index" do
        get :index
        response.should be_success
        assigns(:messages).should_not be_nil
      end

      it "loads twitter searches" do
        TwitterSearch.create(:search_term => "foo")
        get :index

        assigns(:twitter_searches).length.should == 1
        assigns(:twitter_searches).first.should be_a_kind_of(TwitterSearch)
      end
    end

    it "should respond to new" do
      get :new
      response.should be_success
    end

    it "should respond to create" do
      old_count = Message.count
      post :create, :message => {}
      Message.count.should == old_count

      post :create, :message => {:text=>'foo'}
      Message.count.should == old_count + 1

      response.should redirect_to(messages_path)
    end

    it "should respond to edit" do
      get :edit, :id => messages(:company_meeting)
      response.should be_success
    end

    it "should respond to update" do
      put :update, :id => messages(:company_meeting), :message => { }
      response.should redirect_to(messages_path)
    end

    it "should respond to destroy" do
      old_count = Message.count
      delete :destroy, :id => messages(:company_meeting)
      Message.count.should == old_count - 1

      response.should redirect_to(messages_path)
    end
  end
end
