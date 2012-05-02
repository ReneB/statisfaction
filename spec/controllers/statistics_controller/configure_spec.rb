require "spec_helper"

describe Statisfaction::StatisticsController do
  describe :configure do
    before(:each) do
      @block = proc { 1 + 1 }
    end

    it "evaluates the block in the controller context" do
      Statisfaction::StatisticsController.should_receive(:instance_eval).with(&@block)

      Statisfaction::StatisticsController.configure &@block
    end
  end
end
