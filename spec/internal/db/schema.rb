ActiveRecord::Schema.define do
  create_table(:statisfaction_events, :force => true) do |t|
    t.string :for_class
    t.string :event_name

    t.string :subject_id
    t.string :subject_type

    t.timestamps
  end
end
