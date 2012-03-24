Sequel.migration do
  up do
    create_table(:vault) do
      primary_key :id

      String :account
      String :filename
      File :data

      Time :created_on, :default => 'now()'
      Time :updated_on
    end
  end

  down do
    drop_table(:vault)
  end
end
