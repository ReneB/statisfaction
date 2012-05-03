require "spec_helper"

describe Statisfaction::StatisticsController do
  describe :usable_if do
    before(:each) do
      @old_value = Statisfaction::StatisticsController.send(:access_specification)
    end

    after(:each) do
      Statisfaction::StatisticsController.send(:access_specification=, @old_value)
    end

    it "should store the access specifier" do
      block = proc { true }

      Statisfaction::StatisticsController.configure do
        usable_if &block
      end

      Statisfaction::StatisticsController.access_specification.should == block
    end
  end
end
