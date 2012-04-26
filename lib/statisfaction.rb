require 'statisfaction/engine'

module Statisfaction
  mattr_reader :viewable_callback

  # Module methods
  def self.configure(&block)
    module_eval(&block)
  end

  def self.viewable_if(&block)
    @viewable_callback = block
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
    def create_statisfaction_event(method_name)
      ::Statisfaction::Event.create(for_class: self.class.name, event_name: method_name)
    end
  end
end

Object.send(:extend, Statisfaction::ClassMethods)
