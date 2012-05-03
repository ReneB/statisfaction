class Statisfaction::StatisticsController < Statisfaction::ApplicationController
  before_filter :check_access

  def self.configure(&block)
    instance_eval(&block)
  end

  private
  def self.usable_if(&block)
    self.access_specification = block
  end

  def check_access
    return false unless self.class.access_specification.present?

    instance_eval &self.class.access_specification
  end

  # Do not use cattr_accessor since it also introduces an instance
  # reader and writer that might be viewed as actions by Rails.
  def self.access_specification
    @@access_specification ||= nil
  end

  def self.access_specification=(value)
    @@access_specification = value
  end
end
