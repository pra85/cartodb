Sequel.migration do
  up do
    add_column :users, :routing_quota, :integer, null: false, default: 0
    add_column :users, :routing_block_price, :integer
    add_column :organizations, :routing_quota, :integer, null: false, default: 0
    add_column :organizations, :routing_block_price, :integer
  end

  down do
    drop_column :users, :routing_quota
    drop_column :users, :routing_block_price
    drop_column :organizations, :routing_quota
    drop_column :organizations, :routing_block_price
  end
end
