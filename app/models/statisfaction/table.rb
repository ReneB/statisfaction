require 'statisfaction/activity'

module Statisfaction
  class Table
    attr_reader :column_labels

    [:for, :from, :to, :by, :with_subject].each do |method_name|
      define_singleton_method method_name do |*args|
        self.new.send(method_name, *args)
      end
    end

    def for(*args)
      raise "Already specified activities for this table" if @activities_specified
      @activities_specified = true

      @activities = Statisfaction::Activities(*args)
      self.relation = relation.for_activities(*@activities)

      self
    end

    def from(date)
      raise "Already specified start date for this table" if @start_date_specified
      @start_date_specified = true

      self.relation = relation.after(date)

      self
    end

    def to(date)
      raise "Already specified end date for this table" if @end_date_specified
      @end_date_specified = true

      self.relation = relation.before(date)

      self
    end

    def by(granularity)
      raise "Already specified granularity for this table" if @granularity_specified
      @granularity_specified = true

      @granularity = granularity

      # we will support, for example, hour_of_day, day_of_year, day_of_week, day_of_month, week, month and year later on
      # raise "Granularity '#{granularity}' not supported" unless [:hour, :day, :week, :month, :year].include?(granularity)
      raise "Granularity '#{granularity}' not supported" unless granularity == :month

      self.relation = relation.group("CONCAT(year(created_at),'-',month(created_at))")

      add_group_criterium(granularity)

      self
    end

    def with_subject(subject)
      raise "Already specified subject for this table" if @subject_specified
      @subject_specified = true

      self.relation = relation.for_subject(subject)

      self
    end

    def rows
      ensure_calculated!

      table = build_table
      convert_table_timestamps!(table)

      table
    end

    private
    # this method does not work with subjects yet
    def build_table
      columns = get_column_labels
      rows = get_unique_date_labels

      table = rows.inject([columns]) do |current_table, row|
        current_table << build_row(columns, row)
      end

      table
    end

    def build_row(columns, row)
      new_row = columns[1..-1].inject([row]) do |current_row, column|
        relation_key = build_key(row, column)

        current_row << (@calculated_relation[relation_key] || 0)
      end

      new_row
    end

    def build_key(row, column)
      timestamp_index = @group_criteria.index(@granularity)
      activity_index = @group_criteria.index(:activity)

      relation_key = []
      relation_key[timestamp_index] = row
      relation_key[activity_index] = column

      relation_key
    end

    def convert_table_timestamps!(table)
      table[1..-1].each do |row|
        row[0] = DateTime.civil(*row.first.split("-").map(&:to_i))
      end

      table
    end

    # this method does not support using subjects yet
    def get_column_labels
      ensure_calculated!

      activity_label_position = @group_criteria.index(:activity)

      @activities.inject([@granularity.to_s]) do |labels, activity|
        labels << activity.to_param
      end
    end

    def get_unique_date_labels
      ensure_calculated!

      date_label_position = @group_criteria.index(@granularity)

      @calculated_relation.keys.map do |key|
        key[date_label_position]
      end.uniq
    end

    def raise_unless_sufficiently_specified!
      sufficiently_specified = !!(@activities_specified && @granularity_specified)

      raise "Specification for Table not complete - both for() and by() need to be specified" unless sufficiently_specified
    end

    def add_group_criterium(crit)
      @group_criteria ||= []

      @group_criteria << crit
    end

    def relation
      if @relation.nil?
        add_group_criterium(:activity)
        @relation = Statisfaction::Event.grouped_by_activity
      end

      @relation
    end

    def relation=(value)
      @calculated_relation = nil
      @relation = value
    end

    def ensure_calculated!
      raise_unless_sufficiently_specified!

      @calculated_relation = relation.count
    end
  end
end
