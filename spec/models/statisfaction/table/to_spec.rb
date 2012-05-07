require "spec_helper"

describe Statisfaction::Table do
  describe :to do
    before :each do
      @stubbed_relation = mock(:relation, :before => [])
      subject.stub(:relation).and_return(@stubbed_relation)
    end

    it "delegates event fetching to relation" do
      @stubbed_relation.should_receive(:before).with(@start_date)

      subject.to(@start_date)
    end

    it "does not allow a second call" do
      expect {
        subject.to(@start_date).to(@start_date)
      }.to raise_error
    end

    it "delegates to relation.before()" do
      @stubbed_relation.should_receive(:before).with(@start_date)

      subject.to(@start_date)
    end

    it "returns a subject" do
      subject.to(@start_date).should be_a Statisfaction::Table
    end
  end
end
