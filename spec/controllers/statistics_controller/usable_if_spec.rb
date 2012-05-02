require "spec_helper"

describe Statisfaction::StatisticsController do
  describe :usable_if do
    before(:each) do
      @old_value = Statisfaction::StatisticsController.class_variable_get(:@@access_specification)
    end

    after(:each) do
      Statisfaction::StatisticsController.class_variable_set(:@@access_specification, @old_value)
    end

    it "should set @@access_specification" do
      block = proc { true }

      Statisfaction::StatisticsController.usable_if &block

      Statisfaction::StatisticsController.access_specification.should == block
    end
  end
end
