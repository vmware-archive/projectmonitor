require 'spec_helper'

describe AggregateProjectsController, :type => :controller do
  describe "with no logged in user" do
    describe "show" do
      let(:aggregate_project) { aggregate_projects(:internal_projects_aggregate) }
      before { get :show, id: aggregate_project.to_param, format: 'json' }

      it "should be_success" do
        expect(response).to be_success
      end

      it "should render aggregate project" do
        expect(response.body).to eq(aggregate_project.to_json)
      end
    end
  end

  describe "with a logged in user" do
    before { sign_in create(:user) }

    describe "create" do
      context "when the aggregate project was successfully created" do
        before { post :create, aggregate_project: { name: "new name" } }

        it "should set the flash" do
          expect(flash[:notice]).to eq('Aggregate project was successfully created.')
        end

        it { is_expected.to redirect_to edit_configuration_path }
      end

      context "when the aggregate project was not successfully created" do
        before { post :create, aggregate_project: { name: nil } }
        it { is_expected.to render_template :new }
      end
    end

    describe "update" do
      context "when the aggregate project was successfully updated" do
        before { put :update, id: aggregate_projects(:internal_projects_aggregate), aggregate_project: { name: "new name" } }

        it "should set the flash" do
          expect(flash[:notice]).to eq('Aggregate project was successfully updated.')
        end

        it { is_expected.to redirect_to edit_configuration_path }
      end

      context "when the aggregate project was not successfully updated" do
        before { put :update, id: aggregate_projects(:internal_projects_aggregate), aggregate_project: { name: nil } }
        it { is_expected.to render_template :edit }
      end
    end

    describe "destroy" do
      subject { delete :destroy, id: aggregate_projects(:internal_projects_aggregate) }

      it "should destroy the aggregate project" do
        expect { subject }.to change(AggregateProject, :count).by(-1)
      end

      it "should set the flash" do
        subject
        expect(flash[:notice]).to eq('Aggregate project was successfully destroyed.')
      end

      it { is_expected.to redirect_to edit_configuration_path }
    end
  end
end
