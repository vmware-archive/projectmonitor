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
    let!(:entry1) { PayloadLogEntry.create(created_at: 2.years.ago) }
    let!(:entry2) { PayloadLogEntry.create(created_at: 1.year.ago) }
    let!(:entry3) { PayloadLogEntry.create }

    it "should return the latest" do
      expect(PayloadLogEntry.latest).to eq(entry3)
    end
  end

  describe 'record creation' do
    before do
      (0...PayloadLogEntry::LOG_ENTRIES_TO_KEEP).each do |i|
        log = PayloadLogEntry.create(
          created_at: (PayloadLogEntry::LOG_ENTRIES_TO_KEEP - i).days.ago,
          status: 'failed',
          error_text: 'does not matter',
          project_id: 1
        )

        PayloadLogEntry.create(
          created_at: ((PayloadLogEntry::LOG_ENTRIES_TO_KEEP - i) * 10 ).days.ago,
          status: 'failed',
          error_text: 'does not matter',
          project_id: 2
        )

        @oldest_log ||= log
      end

    end

    it 'removes all but the last PayloadLogEntry::LOG_ENTRIES_TO_KEEP logs for a given project' do
      expect(PayloadLogEntry.count).to eq(PayloadLogEntry::LOG_ENTRIES_TO_KEEP*2)

      newest_log = PayloadLogEntry.create(
        created_at: Time.now,
        status: 'failed',
        error_text: 'does not matter',
        project_id:1
      )

      expect(PayloadLogEntry.count).to eq(PayloadLogEntry::LOG_ENTRIES_TO_KEEP*2)
      expect(PayloadLogEntry.where(project_id: 1)).not_to include(@oldest_log)
      expect(PayloadLogEntry.where(project_id: 1)).to include(newest_log)
    end
  end
end

