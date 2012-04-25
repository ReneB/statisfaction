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

  context "when there are multiple statisfy statements" do
    before(:each) do
      class TestSubject
        def method_1 ; end
        def method_2 ; end

        statisfy do
          record :method_1
        end

        statisfy do
          record :method_2
        end
      end
    end

    it "should evaluate them all" do
      [:method_1, :method_2].each do |method|
        subject.should_receive(:create_statisfaction_event).with(method)
      end

      subject.method_1
      subject.method_2
    end
  end

  describe "statisfaction_defaults" do
    before(:each) do
      class TestSubject
        include ActiveRecord::Persistence

        def create ; end
        def update ; end
        def destroy ; end

        statisfy do
          statisfaction_defaults
        end
      end
    end

    context "when the class is an ActiveRecord" do
      [:create, :update, :destroy].each do |method|
        it "should record :#{method}" do
          subject.should_receive(:create_statisfaction_event).with(method)

          subject.send(method)
        end
      end
    end
  end
end
