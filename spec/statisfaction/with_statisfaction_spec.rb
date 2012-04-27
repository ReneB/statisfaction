require "spec_helper"
require_relative "./shared_examples/restoring_activity_status_after_the_block"

describe Statisfaction do
  describe :with_statisfaction do
    before :each do
      @was_active = Statisfaction.active?
      Statisfaction.deactivate
    end

    after :each do
      @was_active ? Statisfaction.activate : Statisfaction.deactivate
    end

    context "within a 'with_statisfaction' block" do
      describe :active? do
        it "always returns true" do
          Statisfaction.with_statisfaction do
            Statisfaction.should be_active
          end
        end
      end
    end

    it_behaves_like "restoring activity status after the block", :with_statisfaction
  end
end
