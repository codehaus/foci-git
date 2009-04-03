class CreatePeriods < ActiveRecord::Migration
  def self.up
    create_table :periods do |t|
      t.column :name, :string, :null => false
      t.column :start, :datetime, :null => false
      t.column :finish, :datetime, :null => false
      t.column :duration, :integer, :null => false
    end
  end

  def self.down
    drop_table :periods
  end
end
