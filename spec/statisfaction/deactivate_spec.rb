require "spec_helper"

describe Statisfaction do
  describe :deactivate do
    before :each do
      @was_deactivated = Statisfaction.instance_variable_get(:@deactivated)
      Statisfaction.instance_variable_set(:@deactivated, false)
    end

    after :each do
      Statisfaction.instance_variable_set(:@deactivated, @was_deactivated)
    end

    it "registers deactivation" do
      expect {
        Statisfaction.deactivate
      }.to change { Statisfaction.active? }.from(true).to(false)
    end
  end
end
