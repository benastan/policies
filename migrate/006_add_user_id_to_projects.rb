Sequel.migration do
  up do
    alter_table :projects do
      add_column :user_id, String
    end
  end

  down do
    alter_table :projects do
      drop_column :user_id
    end
  end
end
