require 'statisfaction/engine'

module Statisfaction
  # Module methods
  def self.configure(&block)
    module_eval(&block)
  end

  module ClassMethods
    def statisfies(&block)
      @statisfier ||= Statisfier.new

      @statisfier.register_events(self, &block)

      include Statisfaction::InstanceMethods
    end

    alias_method :statisfy, :statisfies

    def method_added(method_name)
      @statisfier.new_method_added(method_name) if @statisfier

      super
    end
  end

  module InstanceMethods
    def create_statisfaction_event(method_name, stored_subject = nil)
      event_data = {for_class: self.class.name, event_name: method_name}

      if stored_subject.present?
        event_data[:subject_id] = stored_subject.to_param
        event_data[:subject_type] = stored_subject.class.name
      end
      ::Statisfaction::Event.create(event_data)
    end
  end
end

Object.send(:extend, Statisfaction::ClassMethods)
