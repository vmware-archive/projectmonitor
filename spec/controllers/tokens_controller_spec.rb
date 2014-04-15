require 'spec_helper'

describe TokensController do
  describe "DELETE destroy" do
    let(:user_with_tokens) { FactoryGirl.create(:user, github_token: "github_token", travis_pro_token: "travis_pro_token") }
    let(:user_without_tokens) { FactoryGirl.create(:user) }

    context "when the provider is github" do
      context "with a user who has github/travis pro tokens" do
        before do
          sign_in user_with_tokens
          @user = user_with_tokens
        end

        it "removes github token and travis token from user" do
          delete :destroy, provider: "github"

          @user.reload
          @user.github_token.should be_nil
          @user.travis_pro_token.should be_nil
        end

        it "redirects the user to /configuration/edit" do
          delete :destroy, provider: "github"

          response.should redirect_to "/configuration/edit"
        end
      end

      context "with a user who doesn't have tokens" do
        before do
          sign_in user_without_tokens
        end

        it "redirects the user to /configuration/edit" do
          delete :destroy, provider: "github"

          response.should redirect_to "/configuration/edit"
        end
      end
    end

    context "with an invalid provider" do
      before do
        sign_in user_with_tokens
      end

      it "responds 404" do
        delete :destroy, provider: "anything"
        response.status.should eq(404)
      end
    end
  end
end