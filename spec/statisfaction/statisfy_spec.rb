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
        context "when Statisfaction is active" do
          before :each do
            Statisfaction.stub(:active?).and_return(true)
          end

          it "stores an event" do
            subject.should_receive(:create_statisfaction_event).with(:recorded_method, nil)

            subject.recorded_method
          end
        end

        context "when Statisfaction is deactivated" do
          before :each do
            Statisfaction.stub(:active?).and_return(false)
          end

          it "does not store an event" do
            subject.should_not_receive(:create_statisfaction_event)

            subject.recorded_method
          end
        end
      end


      context "when a subject should be stored" do
        it "should also store the subject" do
          subject.stored_subject = 123
          subject.should_receive(:create_statisfaction_event).with(:recorded_method_with_subject, 123)

          subject.recorded_method_with_subject
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
        attr_accessor :stored_subject

        def recorded_method ; end
        def recorded_method_with_subject ; end
        def not_recorded_method ; end

        statisfy do
          record :recorded_method
          record :recorded_method_with_subject, storing: :stored_subject
        end
      end
    end

    it_behaves_like "statisfied methods"
  end

  context "when the methods are declared after statisfying" do
    before(:each) do
      class TestSubject
        attr_accessor :stored_subject

        statisfy do
          record :recorded_method
          record :recorded_method_with_subject, storing: :stored_subject
        end

        def recorded_method ; end
        def recorded_method_with_subject ; end
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
        subject.should_receive(:create_statisfaction_event).with(method, anything)
      end

      subject.method_1
      subject.method_2
    end
  end

  # A use case for this is recording an ActiveRecord create or update,
  # they both go through #save, but they should be logged under a different
  # name. This means two logging statements should be added.
  context "when the same method is specified twice" do
    before(:each) do
      class TestSubject
        statisfy do
          record :doubly_logged_method, :as => :method_1
          record :doubly_logged_method, :as => :method_2
        end

        # Defining the method after :statisfy would seem to be the difficult case
        def doubly_logged_method ; end
      end
    end

    it "should handle them both" do
      subject.should_receive(:create_statisfaction_event).with(:method_1, anything)
      subject.should_receive(:create_statisfaction_event).with(:method_2, anything)

      subject.doubly_logged_method
    end
  end

  context "when a subject should be stored" do
    before(:each) do
      class TestSubject
        def method ; end

        attr_accessor :stored_subject

        statisfy do
          record :method, storing: :stored_subject
        end
      end

      @subject = TestSubject.new
      @subject.stored_subject = 12
    end

    it "should store it" do
      @subject.should_receive(:create_statisfaction_event).with(:method, 12)
      @subject.method
    end
  end

  context "when a condition is specified" do
    before(:each) do
      class TestSubject
        def method ; end

        attr_accessor :condition
      end
    end

    context "and it is a if statement" do
      before(:each) do
        class TestSubject
          statisfy do
            record :method, if: :condition
          end
        end
      end

      context "and it is true" do
        before(:each) do
          subject.condition = true
        end

        it "should record it" do
          subject.should_receive(:create_statisfaction_event).with(:method, anything)
          subject.method
        end
      end

      context "and it is false" do
        before(:each) do
          subject.condition = false
        end

        it "should not record it" do
          subject.should_not_receive(:create_statisfaction_event)
          subject.method
        end
      end
    end

    context "and it is an unless statement" do
      before(:each) do
        class TestSubject
          statisfy do
            record :method, unless: :condition
          end
        end
      end

      context "and it is true" do
        before(:each) do
          subject.condition = true
        end

        it "should not record it" do
          subject.should_not_receive(:create_statisfaction_event)
          subject.method
        end
      end

      context "and it is false" do
        before(:each) do
          subject.condition = false
        end

        it "should record it" do
          subject.should_receive(:create_statisfaction_event).with(:method, anything)
          subject.method
        end
      end
    end
  end

  context "when :as is specified" do
    before(:each) do
      class TestSubject
        def method ; end

        statisfy do
          record :method, :as => :alias
        end
      end
    end

    it "should record the method under the specified name" do
      subject.should_receive(:create_statisfaction_event).with(:alias, anything)
      subject.method
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
          subject.should_receive(:create_statisfaction_event).with(method, anything)

          subject.send(method)
        end
      end
    end
  end
end
