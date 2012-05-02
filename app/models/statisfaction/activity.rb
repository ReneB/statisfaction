require 'statisfaction/activity/dsl'

module Statisfaction
  class Activity
    def initialize(klass, method)
      self.watched_class = klass
      self.watched_activity = method
    end

    def ==(other)
      self.watched_class == other.watched_class && self.watched_activity == other.watched_activity
    end

    def self.load(serialized)
      self.new *(serialized.split(','))
    end

    def self.dump(obj)
      obj.dump
    end

    def dump
      to_param
    end

    def to_param
      "#{watched_class},#{watched_activity}"
    end

    attr_reader :watched_class, :watched_activity
    protected
    attr_writer :watched_class, :watched_activity
  end
end
