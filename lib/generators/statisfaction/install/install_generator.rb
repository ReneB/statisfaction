require 'rails/generators/active_record'

module Statisfaction
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def generate_migrations
        migration_template "migration.rb", "db/migrate/create_statisfaction_events"
      end

      def generate_initializers
        copy_file "initializer.rb", "config/initializers/statisfaction.rb"
      end

      def mount_engine
        route "mount Statisfaction::Engine => '/statisfaction'" if Rails.version > '3.1'
      end

      def output
        return unless generating?

        puts
        puts "="*80
        puts <<-MESSAGE

Installed Statisfaction. Don't forget to run

  rake db:migrate

and configure view access to generated stats in config/initializers/statisfaction.rb

        MESSAGE
      end

      private
      def generating?
        behavior == :invoke
      end
    end
  end
end
