class Statisfaction::StatisticsController < Statisfaction::ApplicationController
  cattr_reader :access_specification
  before_filter :check_access

  def self.configure(&block)
    instance_eval(&block)
  end

  private
  def self.usable_if(&block)
    @@access_specification = block
  end

  def check_access
    return false unless access_specification.present?

    instance_eval &access_specification
  end
end
