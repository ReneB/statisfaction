module Statisfaction
  extend ActiveSupport::Concern

  mattr_reader :viewable_callback

  # Module methods
  def self.configure(&block)
    module_eval(&block)
  end

  def self.viewable_if(&block)
    @viewable_callback = block
  end

  module ClassMethods
    def statisfier
      @statisfier ||= Statisfier.new
    end

    def statisfies(&block)
      statisfier.register_events(self, &block)

      include Statisfaction::InstanceStatisfaction
    end

    alias_method :statisfy, :statisfies
  end

  module InstanceStatisfaction
    def create_statisfaction_event(method_name)
      ::Statisfaction::Event.create
    end
  end
end

Object.send(:include, Statisfaction)
