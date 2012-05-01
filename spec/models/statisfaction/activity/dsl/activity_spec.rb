require "spec_helper"

describe Statisfaction do
  describe :Activity do
    it "accepts two parameters" do
      expect {
        Statisfaction::Activity(Object, :to_s)
      }.not_to raise_error
    end

    describe "alternative ways of calling Activity()" do
      before :each do
        @normal_activity = Statisfaction::Activity(Object, :to_s)
      end

      it "accepts a properly formatted String" do
        Statisfaction::Activity("Object,to_s").should == @normal_activity
      end

      it "accepts a Hash" do
        Statisfaction::Activity(:class => Object, :activity => :to_s).should == @normal_activity
      end

      it "accepts a Statisfaction::Activity object" do
        Statisfaction::Activity(@normal_activity).should == @normal_activity
      end
    end

    describe "the return value" do
      subject { Statisfaction::Activity(Object, :to_s) }

      it "remembers the class" do
        subject.watched_class.should be(Object)
      end

      it "remembers the activity" do
        subject.watched_activity.should be(:to_s)
      end
    end
  end
end
