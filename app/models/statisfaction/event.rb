require 'statisfaction/activity'

module Statisfaction
  class Event < ActiveRecord::Base
    set_table_name "statisfaction_events"

    scope :for_activities, lambda { |*activities|
      self.where(stored_activity: Statisfaction::Activities(*activities).map(&:to_param))
    }

    scope :after, lambda { |start_date|
      where("#{Statisfaction::Event.table_name}.created_at > :start_date", start_date: start_date)
    }

    scope :before, lambda { |end_date|
      where("#{Statisfaction::Event.table_name}.created_at < :end_date", end_date: end_date)
    }

    scope :for_subject, lambda { |subject|
      where(subject_id: subject.to_param, subject_type: (subject.nil? ? nil : subject.class.name))
    }

    scope :grouped_by_activity, group(:stored_activity)

    def activity=(*args)
      self.stored_activity = Statisfaction::Activity(*args).dump
    end

    def activity
      Statisfaction::Activity(stored_activity)
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
