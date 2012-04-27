require "spec_helper"

describe Statisfaction do
  describe :activate do
    before :each do
      @was_deactivated = Statisfaction.instance_variable_get(:@deactivated)
      Statisfaction.instance_variable_set(:@deactivated, true)
    end

    after :each do
      Statisfaction.instance_variable_set(:@deactivated, @was_deactivated)
    end

    it "registers activation" do
      expect {
        Statisfaction.activate
      }.to change { Statisfaction.active? }.from(false).to(true)
    end
  end
end

