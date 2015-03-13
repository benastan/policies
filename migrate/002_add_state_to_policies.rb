Sequel.migration do
  up do
    alter_table :policies do
      add_column :state, String, default: 'proposal'
    end
  end

  down do
    alter_table :policies do
      drop_column :state, String
    end
  end
end
