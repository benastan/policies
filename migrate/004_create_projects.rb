Sequel.migration do
  up do
    create_table :projects do
      primary_key :id
      String :title
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :projects
  end
end
