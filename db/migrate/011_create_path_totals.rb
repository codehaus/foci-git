class CreatePathTotals < ActiveRecord::Migration
  def self.up
    create_table :path_totals do |t|
      t.column :vhost_id, :integer, :null => false
      t.column :period_id, :integer, :null => false
      t.column :path_id, :integer, :null => false
      
      t.column :response_count, :bigint, :null => false
      t.column :response_bytes, :bigint, :null => false
      t.column :response_bytes_square, :decimal,  :precision => 30, :scale => 0, :null => false
      t.column :response_time, :bigint, :null => false
      t.column :response_time_square, :decimal, :precision => 30, :scale => 0, :null => false
    end
    add_index(:path_totals, [:vhost_id, :period_id, :path_id])
    add_index(:path_totals, [:path_id, :period_id, :vhost_id])
    add_index(:path_totals, [:period_id, :path_id, :vhost_id])
  end

  def self.down
    drop_table :path_totals
  end
end
