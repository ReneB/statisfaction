Statisfaction::StatisticsController.configure do
  usable_if { false }
end

# by default, deactivate Statisfaction when running automated tests
# re-enable by using
#
# Statisfaction.activate
#
# or
#
# Statisfaction.with_statisfaction do
#   [...]
# end
Statisfaction.deactivate if defined?(Rails) && Rails.env.test?
