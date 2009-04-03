class CreatePaths < ActiveRecord::Migration
  def self.up
    create_table :paths do |t|
      t.column :path, :string, :null => false, :unique=>true, :length => 512
    end
    
    Path.connection.execute("CREATE UNIQUE INDEX PATHS_PATH_UK ON PATHS(PATH)")
    Path.connection.execute("CREATE UNIQUE INDEX PATHS_LIKE_PATH_UK ON PATHS USING BTREE(PATH varchar_pattern_ops)")
    Path.connection.execute("CREATE UNIQUE INDEX PATHS_UPPER_PATH_UK ON PATHS(UPPER(PATH))")
    
#    CREATE INDEX PATHS_UPPER_PATH_UK ON PATHS(UPPER(PATH))
  end

  def self.down
    drop_table :paths
  end
end
