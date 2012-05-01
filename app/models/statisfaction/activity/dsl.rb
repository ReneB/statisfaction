module Statisfaction
  class Activity
    module DSL
      def Activity(*args)
        case args.first
        when Class
          build_activity_object args[0], args[1]
        when String
          options = args[0].split(",")
          class_option = options[0].constantize
          activity_option = options[1].to_sym

          build_activity_object(class_option, activity_option)
        when Hash
          options = args[0]
          build_activity_object(options[:class], options[:activity])
        when Statisfaction::Activity
          args[0]
        end
      end

      def Activities(*args)
        activities = []
        while !args.empty? do
          arg = args.shift
          case arg
          when Class
            activities << Statisfaction::Activity(arg, args.shift)
          when String, Statisfaction::Activity
            activities << Statisfaction::Activity(arg)
          when Hash
            activities << Statisfaction::Activity(arg[:class], arg[:activity])
          end
        end

        activities
      end

      private
      def build_activity_object(klass, activity)
        ::Statisfaction::Activity.new(klass, activity)
      end
    end
  end

  extend Activity::DSL
end
