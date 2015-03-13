Sequel.migration do
  up do
    create_table :policies do
      primary_key :id
      String :title
      String :description
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :policies
  end
end
