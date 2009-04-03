class CreateSourcePeriods < ActiveRecord::Migration
  #This links all sources to periods they contain; thus providing us a way to clear out 
  #Everything that is bundled up into a single source/period.
  #
  #It's actually a bit tricky, because a source might span multiple periods; and if it does, then you'll
  #need to clear out all those sources as well, ad infinitum... ouch!
  #It's best to try and align a source and a period using your log configuration to limit this
  def self.up
    create_table :source_periods do |t|
      t.integer :source_id, :null => false
      t.integer :period_id, :null => false
      t.integer :line_count, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :source_periods
  end
end
