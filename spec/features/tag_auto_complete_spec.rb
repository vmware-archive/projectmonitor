require 'spec_helper'

feature "tag auto complete" do
  let!(:user) { create(:user, password: "jeffjeff") }

  before do
    ActsAsTaggableOn::Tag.create! name: 'bar'
    ActsAsTaggableOn::Tag.create! name: 'baz'
    log_in(user, "jeffjeff")
  end

  def select_from_autocomplete(selected)
    within(".ui-autocomplete") do
      all("a").detect {|tag| tag.text == selected }.click
    end
  end

  it "populates a dropdown with possible completions when you type in the tag box", js: true do
    visit(new_project_path)
    fill_in('project[name]', with: 'foo')
    select('Jenkins Project', from: 'Provider')
    choose "Polling"
    fill_in('Base URL', with: 'http://foo.bar.com')
    fill_in('Build Name', with: 'foobar')

    fill_in('Tags', with: 'b')
    select_from_autocomplete('bar')

    fill_in('Tags', with: 'bar, ba')
    select_from_autocomplete('baz')

    click_on 'Create'

    expect(current_path).to eq(edit_configuration_path)

    expect(page).to have_content('bar')
    expect(page).to have_content('baz')
  end
end
