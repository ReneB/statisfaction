module Statisfaction
  module ActivationBehavior
    def active?
      !@deactivated
    end

    def activate
      @deactivated = false
    end

    def deactivate
      @deactivated = true
    end

    def with_statisfaction(&block)
      was_active = active?

      activate

      begin
        yield if block_given?
      ensure
        was_active ? activate : deactivate
      end
    end

    def without_statisfaction(&block)
      was_active = active?

      deactivate

      begin
        yield if block_given?
      ensure
        was_active ? activate : deactivate
      end
    end
  end
end
