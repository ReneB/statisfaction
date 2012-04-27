class Statisfaction::StatisticsController < Statisfaction::ApplicationController
  cattr_reader :access_specification
  before_filter :check_access

  def self.usable_if(&block)
    @@access_specification = block
  end

  private
  def check_access
    return false unless access_specification.present?

    instance_eval &access_specification
  end
end
