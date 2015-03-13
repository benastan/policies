Sequel.migration do
  up do
    create_table :policy_state_changes do
      primary_key :id
      Integer :policy_id
      String :previous_state
      String :new_state
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :policy_state_changes
  end
end
