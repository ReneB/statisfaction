require "spec_helper"
require_relative "./shared_examples/restoring_activity_status_after_the_block"

describe Statisfaction do
  describe :without_statisfaction do
    before :each do
      @was_active = Statisfaction.active?
      Statisfaction.activate
    end

    after :each do
      @was_active ? Statisfaction.activate : Statisfaction.deactivate
    end

    context "within a 'without_statisfaction' block" do
      describe :active? do
        it "always returns false" do
          Statisfaction.without_statisfaction do
            Statisfaction.should_not be_active
          end
        end
      end
    end

    it_behaves_like "restoring activity status after the block", :without_statisfaction
  end
end
