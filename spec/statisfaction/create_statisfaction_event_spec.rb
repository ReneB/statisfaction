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

    context "when no subject is given" do
      describe "the stored event" do
        subject { TestSubject.new.create_statisfaction_event(:event) }

        its(:for_class) { should == TestSubject.name }
        its(:event_name) { should == :event }

        # No subject is given
        its(:subject_id) { should == nil }
        its(:subject_type) { should == nil }
      end
    end

    context "when a subject is given" do
      describe "the stored event" do
        let(:identifier) { "identifier" }

        let(:stored_subject) { mock('stored_subject', to_param: identifier) }

        subject { TestSubject.new.create_statisfaction_event(:event, stored_subject) }

        its(:subject_id) { should == identifier }
        its(:subject_type) { should == stored_subject.class.name }
      end
    end
  end
end
