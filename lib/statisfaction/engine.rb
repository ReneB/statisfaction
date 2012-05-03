if defined?(Rails)
  module Statisfaction
    class Engine < Rails::Engine
      isolate_namespace Statisfaction if Rails.version > '3.1'
    end
  end
end
