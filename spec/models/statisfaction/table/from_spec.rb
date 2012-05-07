require "spec_helper"

describe Statisfaction::Table do
  describe :from do
    before :each do
      @stubbed_relation = mock(:relation, :after => [])
      subject.stub(:relation).and_return(@stubbed_relation)
    end

    it "delegates event fetching to relation" do
      @stubbed_relation.should_receive(:after).with(@start_date)

      subject.from(@start_date)
    end

    it "does not allow a second call" do
      expect {
        subject.from(@start_date).for(@start_date)
      }.to raise_error
    end

    it "delegates to relation.after()" do
      @stubbed_relation.should_receive(:after).with(@start_date)

      subject.from(@start_date)
    end

    it "returns a subject" do
      subject.from(@start_date).should be_a Statisfaction::Table
    end
  end
end
