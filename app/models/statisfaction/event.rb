require 'statisfaction/activity'

module Statisfaction
  class Event < ActiveRecord::Base
    set_table_name "statisfaction_events"

    def activity=(*args)
      self.stored_activity = Statisfaction::Activity(*args).dump
    end

    def activity
      Statisfaction::Activity(stored_activity)
    end

    def self.for_activities(*activities)
      params = Statisfaction::Activities(*activities).map(&:to_param)
      self.where stored_activity: params
    end

    def for_class
      activity.watched_class
    end

    def event_name
      activity.watched_activity
    end
  end
end
