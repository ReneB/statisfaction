require "spec_helper"

describe Statisfaction::Event do
  describe :subject= do
    before(:each) do
      class TestClass
        attr_accessor :to_param
      end

      @event = Statisfaction::Event.new
      @data = TestClass.new
    end

    after(:each) do
      Object.send(:remove_const, :TestClass)
    end

    it "should store the class name" do
      @event.subject = @data

      @event.subject_type.should == "TestClass"
    end

    it "should store the to_param" do
      to_param = "382"
      @data.to_param = to_param

      @event.subject = @data

      @event.subject_id.should == to_param
    end
  end

  describe :subject do
    before(:each) do
      class TestClass
      end

      @event = Statisfaction::Event.new
    end

    after(:each) do
      Object.send(:remove_const, :TestClass)
    end

    context "when no subject is stored" do
      before(:each) do
        @event.subject_type = nil
        @event.subject_id = nil
      end

      it "should be nil" do
        @event.subject.should == nil
      end
    end

    context "when the subject class responds to :find" do
      before(:each) do
        class TestClass
          def self.find
            # This is here so respond_to? returns true.
            # Stubbing :respond_to? seems like a bad idea.
          end
        end
      end

      it "should call :find with the subject_id" do
        the_subject = mock('subject')
        @event.subject_id = 123
        @event.subject_type = "TestClass"

        TestClass.stub(:find).with(123).and_return(the_subject)

        @event.subject.should == the_subject
      end
    end

    context "when the subject class does not respond to :find" do
      it "should raise an error" do
        @event.subject_id = 123
        @event.subject_type = "TestClass"

        expect {
          @event.subject
        }.to raise_error Statisfaction::DeserializationError
      end
    end
  end
end
