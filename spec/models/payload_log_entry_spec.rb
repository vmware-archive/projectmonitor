require 'spec_helper'

describe PayloadLogEntry do

  describe ".reverse_chronological" do
    subject { PayloadLogEntry.reverse_chronological }
    let!(:entry1) { PayloadLogEntry.create(created_at: 2.years.ago) }
    let!(:entry2) { PayloadLogEntry.create(created_at: 1.year.ago) }
    let!(:entry3) { PayloadLogEntry.create }
    it { is_expected.to eq([entry3, entry2, entry1]) }
  end

  describe '.latest' do
    let!(:entry1) { PayloadLogEntry.create(created_at: 2.years.ago, project_id: 1) }
    let!(:entry2) { PayloadLogEntry.create(created_at: 1.year.ago, project_id: 1) }
    let!(:entry3) { PayloadLogEntry.create(project_id: 1) }

    it "should return the latest" do
      expect(PayloadLogEntry.latest).to eq(entry3)
    end
  end
end
