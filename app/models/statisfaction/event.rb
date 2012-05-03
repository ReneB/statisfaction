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

    def subject=(subject)
      self.subject_type = subject.class.name
      self.subject_id = subject.to_param
    end

    def subject
      return nil if subject_type.nil?

      subject_class = self.subject_type.constantize

      unless subject_class.respond_to?(:find)
        error_message = "The class #{subject_class.name} does not support :find"
        raise Statisfaction::DeserializationError.new(error_message)
      end

      subject_class.find(self.subject_id)
    end

    def for_class
      activity.watched_class
    end

    def event_name
      activity.watched_activity
    end
  end
end
