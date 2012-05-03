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

        its(:for_class) { should == TestSubject }
        its(:event_name) { should == :event }

        # No subject is given
        its(:subject) { should == nil }
      end
    end

    context "when a subject is given" do
      let(:stored_subject) { mock('stored_subject') }

      before(:each) do
        @mock_event = mock('event', :activity= => nil, :subject= => nil, :save => nil)

        Statisfaction::Event.stub(:new).and_return(@mock_event)
      end

      it "should store the subject" do
        @mock_event.should_receive(:subject=).with(stored_subject)

        TestSubject.new.create_statisfaction_event(:event, stored_subject)
      end
    end
  end
end
