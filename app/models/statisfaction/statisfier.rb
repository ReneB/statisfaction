module Statisfaction
  class Statisfier < Object
    def initialize
      @methods_pending_for_recording = {}
    end

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
        register_method_for_recording(method_name, options)
      end
    end

    def new_method_added(method_name)
      return if @disable_method_watcher

      return unless @methods_pending_for_recording.has_key?(method_name)

      options = @methods_pending_for_recording.delete(method_name)

      if method_name.present?
        register_existing_method_for_recording(method_name, options)
      end
    end

    private
    def is_active_record?
      @klass.ancestors.include?(ActiveRecord::Persistence)
    end

    def register_method_for_recording(method_name, options)
      if @klass.instance_methods.include?(method_name)
        register_existing_method_for_recording(method_name, options)
      else
        register_nonexistent_method_for_recording(method_name, options)
      end
    end

    def register_existing_method_for_recording(method_name, options)
      # Aliasing a method triggers :method_added for the original method,
      # since we're already handling that, prevent doing that a second time.
      @disable_method_watcher = true

      @klass.class_eval do
        define_method "#{method_name}_with_statisfaction_registration".to_sym do |*method_args|
          subject = options[:storing] ? self.send(options[:storing]) : nil

          self.create_statisfaction_event(method_name, subject) if Statisfaction.active?

          send "#{method_name}_without_statisfaction_registration", *method_args
        end

        alias_method_chain method_name, :statisfaction_registration
      end
    ensure
      @disable_method_watcher = false
    end

    def register_nonexistent_method_for_recording(method_name, options)
      @methods_pending_for_recording[method_name] = options
    end
  end
end
