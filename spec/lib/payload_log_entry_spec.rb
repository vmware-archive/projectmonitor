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

  describe 'database memory management when adding a new failure payload with same error text' do
    random_arbitrary_string = (0...8).map { (65 + rand(26)).chr }.join
    old_date = 1.year.ago
    before(:each) {
      PayloadLogEntry.create(
          created_at: old_date,
          status: 'failed',
          error_text: random_arbitrary_string,
          project_id:1)
    }

    it "should delete the most recent payload if it failed for the same reason" do
      PayloadLogEntry.create(
          status: 'failed',
          error_text: random_arbitrary_string,
          project_id: 1
      )
      expect(PayloadLogEntry.count).to eq(1)
      expect(PayloadLogEntry.where(created_at: old_date).count).to eq(0)
    end

    it "should not delete the most recent payload if a new one comes out that has a different project id" do
      PayloadLogEntry.create(
          status: 'failed',
          error_text: random_arbitrary_string,
          project_id: 2
      )
      expect(PayloadLogEntry.count).to eq(2)
    end

    it "should only delete the most recent payload" do
      PayloadLogEntry.create(
          status: :success,
          project_id: 1
      )
      PayloadLogEntry.create(
          status: 'failed',
          error_text: random_arbitrary_string,
          project_id: 1
      )
      PayloadLogEntry.create(
          status: 'failed',
          error_text: random_arbitrary_string,
          project_id: 1
      )
      expect(PayloadLogEntry.count).to eq(3)
      expect(PayloadLogEntry.where(created_at: old_date).count).to eq(1)

    end

    it "should only delete failure statuses" do
      PayloadLogEntry.create(
          status: 'success',
          project_id: 1,
          error_text: random_arbitrary_string
      )

      PayloadLogEntry.create(
          status: nil,
          project_id: 1,
          error_text: random_arbitrary_string
      )

      PayloadLogEntry.create(
          status: 'failed',
          error_text: random_arbitrary_string,
          project_id: 1
      )

      expect(PayloadLogEntry.count).to eq(4)

    end


  end

end
