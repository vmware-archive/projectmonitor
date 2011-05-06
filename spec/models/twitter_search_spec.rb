require 'spec_helper'

describe TwitterSearch do
  context "validations" do
    it "validates presence of the search term" do
      twitter_search = TwitterSearch.new
      twitter_search.should_not be_valid
      twitter_search.errors[:search_term].should_not be_blank
      
      twitter_search.search_term = "foo"
      twitter_search.should be_valid
    end

    it "validates uniqueness of the search term" do
      twitter_search1 = TwitterSearch.create(:search_term => "foo")
      twitter_search1.new_record?.should be_false

      twitter_search2 = TwitterSearch.new(:search_term => "foo")
      twitter_search2.should_not be_valid
      twitter_search2.errors[:search_term].should_not be_blank
    end
  end

  context "scopes" do
    it "sorts by created_at asc by default" do
      old_first = TwitterSearch.create(:search_term => "foo")
      sleep(1)
      new_last = TwitterSearch.create(:search_term => "bar")

      TwitterSearch.all.should == [old_first, new_last]
    end
  end
end
