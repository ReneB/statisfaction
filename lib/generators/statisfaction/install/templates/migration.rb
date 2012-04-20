<% change_migration = Rails.version >= "3.1"
   method_name = change_migration ? :change : :up -%>
class CreateStatisfactionEvents < ActiveRecord::Migration
  def self.<%= method_name %>
    create_table :statisfaction_events do |t|
      t.string :for_class
      t.string :event_name

      t.integer :subject_id
      t.string :subject_type

      t.timestamps
    end

    # Don't add indices by default since, in most applications, the data is
    # often only appended and rarely read. Uncomment the lines below if you really
    # want indices.
    #add_index :statisfaction_events, :event_source
    #add_index :statisfaction_events, [:event_source, :event_type]
    #add_index :statisfaction_events, [:subject_id, :subject_type]
  end
<% unless change_migration -%>

  def self.down
    drop_table :statisfaction_events
  end
<% end -%>
end
