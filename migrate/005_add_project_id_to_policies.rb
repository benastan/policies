Sequel.migration do
  up do
    alter_table :policies do
      add_column :project_id, Integer
    end
  end

  down do
    alter_table :policies do
      drop_column :project_id, Integer
    end
  end
end
