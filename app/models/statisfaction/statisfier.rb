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

      options_collection = @methods_pending_for_recording.delete(method_name)

      options_collection.each do |options|
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
        logged_name = options[:as] || method_name

        feature_name = "statisfaction_registration_as_#{logged_name}"

        define_method "#{method_name}_with_#{feature_name}".to_sym do |*method_args|
          subject = options[:storing] ? self.send(options[:storing]) : nil

          should_record = Statisfaction::Statisfier.should_record?(options, self)
          result = send "#{method_name}_without_#{feature_name}", *method_args

          if Statisfaction.active? && should_record
            self.create_statisfaction_event(logged_name, subject)
          end

          result
        end

        alias_method_chain method_name, feature_name.to_sym
      end
    ensure
      @disable_method_watcher = false
    end

    def register_nonexistent_method_for_recording(method_name, options)
      stored_options = @methods_pending_for_recording[method_name] ||= []

      stored_options << options
    end

    def self.should_record?(options, object)
      return object.send(options[:if]) if options.has_key?(:if)
      return !object.send(options[:unless]) if options.has_key?(:unless)
      return true
    end
  end
end
