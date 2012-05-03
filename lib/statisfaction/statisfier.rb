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
        ar_create
        ar_update
        ar_destroy
      end
    end

    def ar_create
      record :save, :as => :create, :if => :new_record?
    end

    def ar_update
      record :save, :as => :update, :unless => :new_record?
    end

    def ar_destroy
      record :destroy
    end

    def record(*args)
      options = (args.last.is_a? Hash) ? args.pop : {}

      args.each do |method_name|
        register_method_for_recording(method_name, options)
      end
    end

    def new_method_added(method_name)
      return if @disable_method_watcher

      options_collection = @methods_pending_for_recording.delete(method_name)

      return if options_collection.nil?

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
        stripped_logged_name = logged_name.to_s.sub(/([?!=])$/, '').to_sym

        # Put the old method name at the end so we don't have to strip and re-add any
        # special characters.
        method_name_ending = "as_#{stripped_logged_name}_on_#{method_name}"
        without_method = :"statisfy_without_registration_#{method_name_ending}"
        with_method = :"statisfy_with_registration_#{method_name_ending}"

        define_method(with_method) do |*method_args|
          should_record = Statisfaction::Statisfier.should_record?(options, self)

          result = send(without_method, *method_args)

          if should_record
            subject = options[:storing] ? self.send(options[:storing]) : nil
            self.create_statisfaction_event(logged_name, subject)
          end

          result
        end

        # alias_method_chain makes things much harder when method names with
        # special_characters are specified.
        alias_method without_method, method_name
        alias_method method_name, with_method
      end
    ensure
      @disable_method_watcher = false
    end

    def register_nonexistent_method_for_recording(method_name, options)
      stored_options = @methods_pending_for_recording[method_name] ||= []

      stored_options << options
    end

    def self.should_record?(options, object)
      return false unless Statisfaction.active?

      return object.send(options[:if]) if options.has_key?(:if)
      return !object.send(options[:unless]) if options.has_key?(:unless)
      return true
    end
  end
end
