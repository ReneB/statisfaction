require "spec_helper"

describe Statisfaction::Table do
  before :each do
    @stubbed_activities = []
    @fake_params = [1, 2, 3]

    @stubbed_relation = mock(:relation, :for_activities => [])
    subject.stub(:relation).and_return(@stubbed_relation)

    Statisfaction.stub(:Activities).and_return(@stubbed_activities)
  end

  describe :for do
    it "passes its argument list to Statisfaction::Activities()" do
      Statisfaction.should_receive(:Activities).with(*@fake_params).and_return(@stubbed_activities)

      subject.for(*@fake_params)
    end

    it "delegates event fetching to relation" do
      @stubbed_relation.should_receive(:for_activities).with(*@stubbed_activities)

      subject.for(*@fake_params)
    end

    it "does not allow a second call" do
      expect {
        subject.for(*@fake_params).for(*@fake_params)
      }.to raise_error
    end

    it "returns a Statisfaction::Table" do
      subject.for(@fake_params).should be_a Statisfaction::Table
    end
  end
end
