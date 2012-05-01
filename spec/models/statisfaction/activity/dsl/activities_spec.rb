require "spec_helper"

describe Statisfaction do
  describe :Activities do
    it "returns an array" do
      Statisfaction::Activities(Object, :to_s).should be_an Array
    end

    describe "alternative ways of calling" do
      before :each do
        @normal_activities = Statisfaction::Activities(Object, :to_s)
      end

      it "accepts the String form" do
        Statisfaction::Activities("Object,to_s").should == @normal_activities
      end

      it "accepts the Hash form" do
        Statisfaction::Activities(:class => Object, :activity => :to_s).should == @normal_activities
      end

      it "accepts the Statisfaction::Activity form" do
        Statisfaction::Activities(*@normal_activities).should == @normal_activities
      end

      it "accepts mixed-form calls" do
        activities = Statisfaction::Activities(Object, :to_s,
                                        "Object,id",
                                        :class => Object, :activity => :instance_eval)

        activities.map(&:class).should == [ Statisfaction::Activity, Statisfaction::Activity, Statisfaction::Activity]
      end
    end
  end
end
