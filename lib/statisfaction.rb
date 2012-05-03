require 'statisfaction/engine'
require 'statisfaction/activation_behavior'
require 'statisfaction/statisfier'
require 'statisfaction/errors'

module Statisfaction
  extend ActivationBehavior
  # Module methods
  def self.configure(&block)
    module_eval(&block)
  end

  module ClassMethods
    def statisfies(&block)
      @statisfier ||= Statisfier.new

      @statisfier.register_events(self, &block)

      include Statisfaction::InstanceMethods

      def self.method_added(method_name)
        @statisfier.new_method_added(method_name) if @statisfier

        super
      end
    end

    alias_method :statisfy, :statisfies
  end

  module InstanceMethods
    def create_statisfaction_event(method_name, stored_subject = nil)
      event_data = {}

      Statisfaction::Event.new(event_data).tap do |e|
        e.activity = { class: self.class, activity: method_name }

        e.subject = stored_subject if stored_subject.present?

        e.save
      end
    end
  end
end

Object.send(:extend, Statisfaction::ClassMethods)
