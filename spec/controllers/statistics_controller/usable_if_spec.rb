require "spec_helper"

describe Statisfaction::StatisticsController do
  describe :usable_if do
    it "should set @@access_specification" do
      block = proc { true }

      Statisfaction::StatisticsController.usable_if &block

      Statisfaction::StatisticsController.access_specification.should == block
    end
  end
end
