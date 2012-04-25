require "spec_helper"

require "statisfaction"

describe Statisfaction do
  before(:each) do
    class TestSubject
      statisfy do
      end
    end
  end

  after(:each) do
    Object.send(:remove_const, :TestSubject)
  end

  subject { TestSubject.new }

  context "when create_statisfaction_event is called" do
    it "should store a Statisfaction::Event" do
      expect {
        subject.create_statisfaction_event(:event)
      }.to change { Statisfaction::Event.count }.by(1)
    end
  end
end
