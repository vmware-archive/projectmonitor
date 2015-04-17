require 'spec_helper'

describe 'TrimPayloadLogEntries' do
  describe 'run' do
    before do
      create(:project, id: 1)
      create(:project, id: 2)
      create(:project, id: 3)
      (0...TrimPayloadLogEntries::LOG_ENTRIES_TO_KEEP/2).each do |i|
        log = PayloadLogEntry.create(
          created_at: (TrimPayloadLogEntries::LOG_ENTRIES_TO_KEEP - i).days.ago,
          project_id: 1
        )

        @oldest_log ||= log
      end

      (0...TrimPayloadLogEntries::LOG_ENTRIES_TO_KEEP).each do |i|
        log = PayloadLogEntry.create(
          created_at: (TrimPayloadLogEntries::LOG_ENTRIES_TO_KEEP - i).days.ago,
          project_id: 2
        )

        @oldest_log2 ||= log
      end

      (0...TrimPayloadLogEntries::LOG_ENTRIES_TO_KEEP*2).each do |i|
        log = PayloadLogEntry.create(
          created_at: (TrimPayloadLogEntries::LOG_ENTRIES_TO_KEEP - i).days.ago,
          project_id: 3
        )

        @oldest_log3 ||= log
      end
    end

    it 'removes all but the last TrimPayloadLogEntries::LOG_ENTRIES_TO_KEEP logs for a given project' do

      expect(PayloadLogEntry.count).to eq(70)
      TrimPayloadLogEntries.new.run
      expect(PayloadLogEntry.count).to eq(TrimPayloadLogEntries::LOG_ENTRIES_TO_KEEP*2 + (TrimPayloadLogEntries::LOG_ENTRIES_TO_KEEP/2))

      expect(PayloadLogEntry.where(project_id: 1)).to include(@oldest_log)
      expect(PayloadLogEntry.where(project_id: 2)).to include(@oldest_log2)
      expect(PayloadLogEntry.where(project_id: 3)).to_not include(@oldest_log3)
    end
  end
end
