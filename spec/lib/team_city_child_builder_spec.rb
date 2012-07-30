require 'spec_helper'

describe TeamCityChildBuilder do
  let(:parent) do
    FactoryGirl.build(
      :team_city_chained_project,
      auth_username: 'john',
      auth_password: 'secret')
  end
  let(:parsed) { TeamCityChildBuilder.parse(parent, content) }
  let(:content) do
    <<-XML
    <buildType id="bt12398" webUrl="http://example2.com/viewType.html?buildTypeId=bt12398">
      <snapshot-dependencies>
        <snapshot-dependency id="bt3" type="snapshot_dependency" />
        <snapshot-dependency id="bt5" type="snapshot_dependency" />
        <snapshot-dependency id="bt9" type="snapshot_dependency" />
      </snapshot-dependencies>
    </buildType>
    XML
  end

  it "assigns the correct feed_url to all children builds" do
    [3,5,9].each do |i|
      parsed.collect(&:feed_url).should(
        include("http://example2.com/app/rest/builds?locator=running:all,buildType:(id:bt#{i})")
      )
    end
  end

  it "assigns the correct team_city_rest_build_type_id to all children builds" do
    [3,5,9].each do |i|
      parsed.collect(&:team_city_rest_build_type_id).should(
        include("bt#{i}")
      )
    end
  end

  it "assigns the correct auth_username to all children builds" do
    [3,5,9].each do |i|
      parsed.collect(&:auth_username).should(
        include("john")
      )
    end
  end

  it "assigns the correct auth_username to all children builds" do
    [3,5,9].each do |i|
      parsed.collect(&:auth_password).should(
        include("secret")
      )
    end
  end
end
