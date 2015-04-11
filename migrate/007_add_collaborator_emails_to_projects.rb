Sequel.migration do
  up do
    alter_table :projects do
      add_column :collaborator_emails, :'text[]'
    end
  end

  down do
    alter_table :projects do
      drop_column :collaborator_emails
    end
  end
end
