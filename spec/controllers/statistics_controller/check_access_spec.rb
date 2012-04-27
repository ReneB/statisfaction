require "spec_helper"

describe Statisfaction::StatisticsController do
  let(:controller_class) { Statisfaction::StatisticsController }
  subject { controller_class.new }

  describe :check_access do
    context "when @access_specification does not exist" do
      before(:each) do
        controller_class.stub(:access_specification).and_return(nil)
      end

      it "is false" do
        subject.send(:check_access).should == false
      end
    end

    context "when it is configured" do
      context "when the block returns true" do
        before(:each) do
          controller_class.usable_if { true }
        end

        it "is true" do
          subject.send(:check_access).should == true
        end
      end

      context "when the block returns false" do
        before(:each) do
          controller_class.usable_if { false }
        end

        it "is false" do
          subject.send(:check_access).should == false
        end
      end

      describe "the block" do
        before(:each) do
          @block = proc { true }

          controller_class.usable_if &@block
        end

        it "is evaluated within the context of the controller" do
          subject.should_receive(:instance_eval).with(&@block)

          subject.send(:check_access)
        end
      end
    end
  end
end

