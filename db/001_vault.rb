Sequel.migration do
  up do
    create_table(:vault) do
      primary_key :id

      String :account, :null => false
      String :filename, :null => false
      File :data, :null => false

      Time :created_on, :null => false
      Time :updated_on, :null => false
    end
  end

  down do
    drop_table(:vault)
  end
end
