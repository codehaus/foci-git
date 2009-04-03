class AddLineCount < ActiveRecord::Migration
  def self.up
    add_column :sources, :line_count, :integer, :null => true, :default => 0
  end

  def self.down
    remove_column :sources, :line_count
  end
end
