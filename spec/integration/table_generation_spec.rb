require "spec_helper"

describe Statisfaction::Table do
  before :each do
    @granularity = :month
  end

  describe "underspecified tables" do
    it "cannot be generated" do
      table = Statisfaction::Table.for(Object, :to_s)

      expect {
        table.to_array
      }.to raise_error
    end
  end

  describe "a table with zero events" do
    before :each do
      Statisfaction::Event.destroy_all
      @activity = Statisfaction::Activity(Object, :to_s)
      @table = Statisfaction::Table.for(@activity).by(@granularity)
    end

    it "only contains the header row" do
      @table.rows.size.should be(1)
    end

    describe "the header row" do
      subject { @table.rows.first }

      it { should include(@activity.to_param) }
      it { should include(@granularity.to_s) }
    end
  end

  describe "a table with events" do
    before :each do
      class TestClass
        statisfies {
          record :test_activity
        }
        def test_activity; end
      end

      @table = Statisfaction::Table.for(TestClass, :test_activity).by(@granularity)
    end

    after :each do
      Object.send(:remove_const, :TestClass)
    end

    context "when the event occurred 5 times in the same month" do
      before :each do
        5.times do TestClass.new.test_activity end
      end

      describe "the resulting table" do
        it "has 2 rows" do
          @table.rows.size.should == 2
        end

        it "has 2 columns" do
          @table.rows.first.size.should == 2
        end

        it "states that the event occurred 5 times" do
          datarow = @table.rows.last
          count = datarow[1]
          count.should be 5
        end
      end
    end

    context "when the event occurred once last month and 4 times in this month" do
      before :each do
        5.times do TestClass.new.test_activity end
        Statisfaction::Event.last.tap do |event|
          event.created_at -= 1.month
          event.save
        end
      end

      describe "the resulting table" do
        it "has 3 rows" do
          @table.rows.size.should == 3
        end

        it "has 2 columns" do
          @table.rows.first.size.should == 2
        end

        it "states that the event occurred once during last month" do
          datarow = @table.rows.find { |row|
            row.first == 1.month.ago.beginning_of_month
          }

          count = datarow[1]
          count.should be 1
        end

        it "states that the event occurred 4 times in this month" do
          datarow = @table.rows.find { |row|
            row.first == Date.today.beginning_of_month
          }

          count = datarow[1]
          count.should be 4
        end
      end
    end
  end
end
