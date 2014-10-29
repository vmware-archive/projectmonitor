require 'spec_helper'

describe UsersController, :type => :controller do
  it "requires login" do
    get :new
    expect(response).to redirect_to(new_user_session_path)
  end

  describe "logged in as a user" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in(user) }

    it "shows a login page" do
      get :new
      expect(response).to be_success
      expect(assigns(:user)).to be_new_record
    end

    it "creates a new user" do
      expect {
        post :create, user: { login: 'newuser', email: 'newuser@example.com',
          password: 'password', password_confirmation: 'password' }
        expect(response).to redirect_to(root_path)
        expect(assigns(:user)).not_to be_new_record
        expect(assigns(:user)).to be_valid
        expect(assigns(:user).login).to eq("newuser")
      }.to change(User, :count).by(1)
    end

    it "should handle a bad user" do
      expect {
        post :create, user: { login: 'newuser', email: 'newuser@example.com',
          password: 'password', password_confirmation: 'notpassword' }
        expect(response).to be_success
        expect(assigns(:user)).not_to be_valid
      }.to change(User, :count).by(0)
    end
  end

  it "should generate params for users's new action from GET /users" do
    expect({get: "/users/new"}).to route_to(controller: 'users', action: 'new')
    expect({post: "/users"}).to route_to(controller: 'users', action: 'create')
  end
end
