require "spec_helper"

require "statisfaction"

describe Statisfaction do
  after(:each) do
    Object.send(:remove_const, :TestSubject)
  end

  subject { TestSubject.new }

  shared_examples_for "statisfied methods" do
    context "when an Object is statisfied" do
      context "when a specified method is called" do
        it "should store an event" do
          subject.should_receive(:create_statisfaction_event).with(:recorded_method)

          subject.recorded_method
        end
      end

      context "when a not-specified method is called" do
        it "should not store an event" do
          subject.should_not_receive(:create_statisfaction_event)

          subject.not_recorded_method
        end
      end
    end
  end

  context "when the methods are declared before statisfying" do
    before(:each) do
      class TestSubject
        def recorded_method ; end
        def not_recorded_method ; end

        statisfy do
          record :recorded_method
        end
      end
    end

    it_behaves_like "statisfied methods"
  end

  context "when the methods are declared after statisfying" do
    before(:each) do
      class TestSubject
        statisfy do
          record :recorded_method
        end

        def recorded_method ; end
        def not_recorded_method ; end
      end
    end

    it_behaves_like "statisfied methods"
  end

  describe "statifier_defaults" do
    before(:each) do
      class TestSubject
        statisfy do
          statisfier_defaults
        end
      end
    end
    context "when the class is an ActiveRecord" do
      it "should record :create, :update, :destroy"
    end
  end
end
