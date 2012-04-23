module Statisfaction
  class Statisfier < Object
    def register_events(klass, &block)
      @klass = klass

      if block_given?
        instance_eval(&block)
      else
        statisfaction_defaults
      end
    end

    def statisfaction_defaults
      if is_active_record?
        record :create, :update, :destroy
      end
    end

    def record(*args)
      options = (args.last.is_a? Hash) ? args.pop : {}

      args.each do |method_name|
        register_method_for_recording(method_name)
      end
    end

    private
    def is_active_record?
      @klass.ancestors.include?(ActiveRecord::Persistence)
    end

    def register_method_for_recording(method_name)
      @klass.class_eval do
        define_method "#{method_name}_with_statisfaction_registration".to_sym do |*method_args|
          self.create_statisfaction_event(method_name)

          send "#{method_name}_without_statisfaction_registration", *method_args
        end

        alias_method_chain method_name, :statisfaction_registration
      end
    end
  end
end
