class CreatePeriodGroupPeriods < ActiveRecord::Migration
  def self.up
    create_table :period_group_periods do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :period_group_periods
  end
end
