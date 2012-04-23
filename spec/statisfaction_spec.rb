require "spec_helper"

require "statisfaction"

describe Statisfaction do
  it "should add class methods to Object" do
    [:statisfy, :statisfies].each do |method_name|
      Object.public_methods.should include method_name
    end
  end

  context "when an Object is statisfied" do
    before(:each) do

      class TestSubject
        def recorded_method ; end
        def not_recorded_method ; end

        statisfy do
          record :recorded_method
        end
      end
    end

    after(:each) do
      Object.send(:remove_const, :TestSubject)
    end

    context "when a specified method is called" do
      subject { TestSubject.new }

      it "should store an event" do
        subject.should_receive(:create_statisfaction_event).with(:recorded_method)

        subject.recorded_method
      end
    end

    context "when a not-specified method is called" do
      subject { TestSubject.new }

      it "should not store an event" do
        subject.should_not_receive(:create_statisfaction_event)

        subject.not_recorded_method
      end
    end
  end
end
