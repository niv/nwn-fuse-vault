Sequel.migration do
  up do
    alter_table(:vault) do
      add_index [:account]
      add_index [:account, :filename],
        :unique => true
    end
  end

  down do
    alter_table(:vault) do
      drop_index [:account]
      drop_index [:account, :filename]
    end
  end
end
