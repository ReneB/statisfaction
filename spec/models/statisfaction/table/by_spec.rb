require "spec_helper"

describe Statisfaction::Table do
  describe :by do
    it "does not allow a second call" do
      expect {
        subject.by(:month).by(:month)
      }.to raise_error
    end
  end
end
