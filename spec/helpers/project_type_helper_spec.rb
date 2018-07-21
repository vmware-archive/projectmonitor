describe ProjectTypeHelper do
  it 'raises error for invalid project type' do
    expect {ProjectTypeHelper.find_type('InvalidType')}.to raise_error(/Invalid Project Type/)
  end

  it 'find_type JenkinsProject' do
    expect(ProjectTypeHelper.find_type('JenkinsProject')).to eq(JenkinsProject)
  end

  it 'find_type CruiseControlProject' do
    expect(ProjectTypeHelper.find_type('CruiseControlProject')).to eq(CruiseControlProject)
  end

  it 'find_type SemaphoreProject' do
    expect(ProjectTypeHelper.find_type('SemaphoreProject')).to eq(SemaphoreProject)
  end

  it 'find_type TeamCityRestProject' do
    expect(ProjectTypeHelper.find_type('TeamCityRestProject')).to eq(TeamCityRestProject)
  end

  it 'find_type TeamCityProject' do
    expect(ProjectTypeHelper.find_type('TeamCityProject')).to eq(TeamCityProject)
  end

  it 'find_type TravisProject' do
    expect(ProjectTypeHelper.find_type('TravisProject')).to eq(TravisProject)
  end

  it 'find_type TravisProProject' do
    expect(ProjectTypeHelper.find_type('TravisProProject')).to eq(TravisProProject)
  end

  it 'find_type TddiumProject' do
    expect(ProjectTypeHelper.find_type('TddiumProject')).to eq(TddiumProject)
  end

  it 'find_type CircleCiProject' do
    expect(ProjectTypeHelper.find_type('CircleCiProject')).to eq(CircleCiProject)
  end

  it 'find_type ConcourseV1Project' do
    expect(ProjectTypeHelper.find_type('ConcourseV1Project')).to eq(ConcourseV1Project)
  end

  it 'find_type ConcourseProject' do
    expect(ProjectTypeHelper.find_type('ConcourseProject')).to eq(ConcourseProject)
  end

  it 'find_type CodeshipProject' do
    expect(ProjectTypeHelper.find_type('CodeshipProject')).to eq(CodeshipProject)
  end
end
