shared_examples_for "restoring activity status after the block" do |method_name|
  context "if Statisfaction was active before" do
    describe Statisfaction do
      before :each do
        Statisfaction.activate
      end

      context 'afterwards' do
        before :each do
          Statisfaction.send(method_name) do
            1 + 1
          end
        end

        it "is active again" do
          Statisfaction.should be_active
        end

        context "even if an error occurred in the block" do
          before :each do
            begin
              Statisfaction.send(method_name) do
                raise "some error"
              end
            rescue; end
          end

          it "restores the activity status" do
            Statisfaction.should be_active
          end
        end
      end
    end
  end

  context "if Statisfaction was inactive before" do
    describe Statisfaction do
      before :each do
        Statisfaction.deactivate
      end

      context 'afterwards' do
        before :each do
          Statisfaction.send(method_name) do
            1 + 1
          end
        end

        it "is inactive again" do
          Statisfaction.should_not be_active
        end

        context "even if an error occurred in the block" do
          before :each do
            begin
              Statisfaction.send(method_name) do
                raise "some error"
              end
            rescue; end
          end

          it "restores the activity status" do
            Statisfaction.should_not be_active
          end
        end
      end
    end
  end
end
