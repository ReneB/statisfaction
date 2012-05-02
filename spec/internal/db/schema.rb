ActiveRecord::Schema.define do
  create_table(:statisfaction_events, :force => true) do |t|
    t.string :stored_activity

    t.string :subject_id
    t.string :subject_type

    t.timestamps
  end
end
