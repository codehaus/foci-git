class CreateRejectedLines < ActiveRecord::Migration
  def self.up
    create_table :rejected_lines do |t|
      t.integer :source_id, :null => false
      t.integer :line_number, :null => false
      t.string  :line_text, :limit => 65535, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :rejected_lines
  end
end
