require 'spec_helper'

describe DashboardGrid do

  let(:projects) do
    [
      FactoryGirl.build(:project, name: "Other 1"),
      FactoryGirl.build(:project, location: "Boston", name: "Boston 1"),
      FactoryGirl.build(:project, location: "SF", name: "San Francisco 1"),
      FactoryGirl.build(:project, location: "SF", name: "San Francisco 2", code: "AA"),
      FactoryGirl.build(:project, location: "NYC", name: "New York")]
  end

  describe '.arrange' do

    context 'when grouping by location' do
      subject { DashboardGrid.arrange(projects, :view => 'location') }

      it 'should return 63 tiles' do
        subject.size.should == 63
      end

      it 'should arrange the tiles correctly' do
        subject.map(&:to_s).should == [
          "SF",               "Boston",     "NYC",      "Other",    "", "", "",
          "San Francisco 2",  "Boston 1",   "New York", "Other 1",  "", "", "",
          "San Francisco 1",  "",           "",         "",         "", "", "",
          "",                 "",           "",         "",         "", "", "",
          "",                 "",           "",         "",         "", "", "",
          "",                 "",           "",         "",         "", "", "",
          "",                 "",           "",         "",         "", "", "",
          "",                 "",           "",         "",         "", "", "",
          "",                 "",           "",         "",         "", "", ""
        ]
      end
    end

    context 'when not grouping by location' do
      context 'and a grid size is specified' do
        subject { DashboardGrid.arrange(projects, :tiles_count => 24) }

        it 'should return 24 tiles' do
          subject.size.should == 24
        end

        it 'should arrange the tiles correctly' do
          subject.map(&:to_s).should == [
            "San Francisco 2",  "Boston 1", "New York", "Other 1",
            "San Francisco 1",  "",         "",         "",
            "",                 "",         "",         "",
            "",                 "",         "",         "",
            "",                 "",         "",         "",
            "",                 "",         "",         ""]
        end
      end

      context 'and no grid size has been specified' do
        subject { DashboardGrid.arrange(projects) }

        it 'should return 15 tiles' do
          subject.size.should == 15
        end
      end
    end

  end

end
