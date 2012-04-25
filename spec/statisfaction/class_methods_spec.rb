require "spec_helper"

require "statisfaction"

describe Statisfaction do
  describe "class methods" do
    it "should add class methods to Object" do
      [:statisfy, :statisfies].each do |method_name|
        Object.public_methods.should include method_name
      end
    end
  end
end
