require 'spec_helper'

describe "tag auto complete", js: true do
  before do
    log_in
  end

  def select_from_autocomplete(selected)
    sleep(1)
    check_for_correct_suggestions
    selector = ".ui-menu-item a:contains(#{selected})"
    page.execute_script " $('#{selector}').trigger(\"mouseenter\").click();"
  end

  def check_for_correct_suggestions
    within '.ui-autocomplete.ui-menu' do
      page.should have_content('bar')
      page.should have_content('baz')
    end
  end

  it "populates a dropdown with possible completions when you type in the tag box" do
    Tag.create! name: 'bar'
    Tag.create! name: 'baz'

    visit(new_project_path)
    fill_in('Name', with: 'foo')
    select('Jenkins Project', from: 'Project Type')
    fill_in('Base URL', with: 'http://foo.bar.com')
    fill_in('Build Name', with: 'foobar')

    fill_in('Tags', with: 'b')
    select_from_autocomplete('bar')

    fill_in('Tags', with: 'bar, ba')
    select_from_autocomplete('baz')

    click_on 'Create'

    current_path.should == edit_configuration_path
    page.should have_content('bar, baz')
  end
end

