require 'spec_helper'
require 'time'

describe ProjectsController do
  describe "with a logged in user" do
    before do
      @current_user = FactoryGirl.create(:user)
      sign_in @current_user
    end

    context "when nested under an aggregate project" do
      it "should scope by aggregate_project_id" do
        Project.should_receive(:with_aggregate_project).with('1')
        get :index, aggregate_project_id: 1
      end
    end

    describe "#index" do
      let!(:projects) { [FactoryGirl.create(:jenkins_project)] }
      let!(:aggregate_project) { FactoryGirl.create(:aggregate_project) }
      let!(:aggregate_projects) { [aggregate_project] }
      let(:tags) { 'bleecker' }

      before do
        AggregateProject.stub(:displayable).and_return(aggregate_projects)
        Project.stub_chain(:standalone, :displayable).and_return(projects)
        projects.stub_chain(:concat, :sort_by).and_return(projects + aggregate_projects)
      end

      it "should render collection of projects as JSON" do
        ProjectFeedDecorator.should_receive(:decorate).with(projects + aggregate_projects)
        get :index, format: :json
      end

      it 'gets a collection of aggregate projects by tag' do
        AggregateProject.should_receive(:displayable).with(tags)
        Project.standalone.should_receive(:displayable).with(tags)
        get :index, tags: tags, format: :json
      end

    end

    describe "#create" do
      context "when the project is valid" do
        def do_post
          post :create, :project => {
            :name => 'name',
            :type => JenkinsProject.name,
            :jenkins_base_url => 'http://www.example.com',
            :jenkins_build_name => 'example'
          }
        end

        it "should create a project of the correct type" do
          lambda { do_post }.should change(JenkinsProject, :count).by(1)
        end

        it "should set the project's creator'" do
          do_post
          Project.last.creator.should == @current_user
        end

        it "should set the flash" do
          do_post
          flash[:notice].should == 'Project was successfully created.'
        end

        it { do_post.should redirect_to edit_configuration_path }
      end

      context "when the project is invalid" do
        before { post :create, :project => { :name => nil, :type => JenkinsProject.name} }
        it { should render_template :new }
      end
    end

    describe "#update" do
      context "when the project was successfully updated" do
        before { put :update, :id => projects(:jenkins_project), :project => { :name => "new name" } }

        it "should set the flash" do
          flash[:notice].should == 'Project was successfully updated.'
        end

        it { should redirect_to edit_configuration_path }
      end

      context "when the project was not successfully updated" do
        before { put :update, :id => projects(:jenkins_project), :project => { :name => nil } }
        it { should render_template :edit }
      end


      describe "feed password" do
        let(:project) { projects(:socialitis).tap {|p| p.auth_password = 'existing password'} }
        subject { project.auth_password }
        before do
          put :update, :id => projects(:socialitis).id, :password_changed => changed, :project => {:auth_password => new_password }
          project.reload
        end

        context 'when the password has been changed' do
          let(:changed) { 'true' }

          context 'when the new password is not present' do
            let(:new_password) { nil }
            it { should be_nil }
          end
          context 'when the new password is present but empty' do
            let(:new_password) { '' }
            it { should be_nil }
          end
          context 'when the new password is not empty' do
            let(:new_password) { 'new password' }
            it { should == new_password }
          end
        end

        context 'when the password has not been changed' do
          let(:changed) { 'false' }

          after { it {should == 'existing_password'} }

          context 'when the new password is not present' do
            let(:new_password) { nil }
          end
          context 'when the new password is present but empty' do
            let(:new_password) { '' }
          end
          context 'when the new password is not empty' do
            let(:new_password) { 'new_password' }
          end
        end

      end

      describe "changing STI type" do
        subject { put :update, "id"=> project.id, "project" => project_params }
        let!(:project) { FactoryGirl.create(:team_city_project) }

        context "when the parameters are valid" do
          let(:project_params) { {"type"=>"JenkinsProject", name: "foobar", "jenkins_base_url"=>"http://foo", "jenkins_build_name"=>"NAMe"} }
          it "should validate as the new type and save the record" do
            subject
            (Project.find(project.id).is_a? JenkinsProject).should be_true
          end
        end

        context "when the parameters are not valid" do

          let(:project_params) { {"type"=>"JenkinsProject", "jenkins_build_name"=>"NAMe"} }
          it "should validate as the new type and save the record" do
            subject
            (Project.find(project.id).is_a? TeamCityProject).should be_true
          end
        end
      end
    end

    describe "#destroy" do
      subject { delete :destroy, :id => projects(:jenkins_project) }

      it "should destroy the project" do
        lambda { subject }.should change(JenkinsProject, :count).by(-1)
      end

      it "should set the flash" do
        subject
        flash[:notice].should == 'Project was successfully destroyed.'
      end

      it { should redirect_to edit_configuration_path }
    end

    describe "#validate_tracker_project" do
      it "should enqueue a job" do
        project = projects(:jenkins_project)
        TrackerProjectValidator.should_receive(:delay) { TrackerProjectValidator }
        TrackerProjectValidator.should_receive :validate
        post :validate_tracker_project, { auth_token: "12354", project_id: "98765", id: project.id }
      end
    end

    describe '#validate_build_info' do
      let(:parsed_response) { JSON.parse(post(:validate_build_info, {project: {type: TravisProject}}).body)}

      context 'when the payload is invalid' do
        before(:each) { ProjectUpdater.should_receive(:update).and_return(log_entry) }

        let(:log_entry) { PayloadLogEntry.new(status: 'failed', error_type: 'MockExceptionClass', error_text: error_text) }
        let(:error_text) { 'Mock error description'}

        context 'should set success flag to true' do
          subject { parsed_response['status'] }
          it { should be_false }
        end

        context 'should set error_class to correct exception' do
          subject { parsed_response['error_type'] }
          it { should == 'MockExceptionClass' }
        end

        context 'should set error_text to correct text' do
          subject { parsed_response['error_text'] }
          context 'with a short description' do
            it { should == 'Mock error description' }
          end

          context 'with a long description' do
            let(:error_text) { 'a'*50000 }
            it { should == 'a'*10000 }
          end
        end
      end

      context 'when the payload is valid' do
        before(:each) { ProjectUpdater.should_receive(:update).and_return(log_entry) }
        let(:log_entry) { PayloadLogEntry.new(status: 'successful', error_type: nil, error_text: '') }

        context 'should set success flag to false' do
          subject { parsed_response['status'] }
          it { should be_true }
        end

        context 'should set error_class to nil' do
          subject { parsed_response['error_type'] }
          it { should be_nil }
        end

        context 'should set error_text to empty string' do
          subject { parsed_response['error_text'] }
          it { should == '' }
        end
      end

      context "for a project with a saved password" do
        context "when a new password is entered in the form" do
          let!(:project) { FactoryGirl.create(:team_city_project, "auth_password" => "password") }

          it "should grab the existing project password" do
            Project.should_not_receive(:find).with(project.id.to_s)
            post :validate_build_info, {project: project.attributes}
          end
        end

        context "when a new password is not entered in the form" do
          let!(:project) { FactoryGirl.create(:team_city_project, "auth_password" => "") }

          it "should use the saved password to fetch" do
            Project.should_receive(:find).with(project.id.to_s)
            post :validate_build_info, {project: project.attributes}
          end
        end
      end
    end
  end
end
