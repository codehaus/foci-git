class AddSpecialIndexes < ActiveRecord::Migration
  def self.up
    Path.connection.execute("DROP INDEX PATHS_PATH_UK")
    Path.connection.execute("CREATE UNIQUE INDEX PATHS_PATH_UK ON PATHS USING BTREE(PATH VARCHAR_PATTERN_OPS)")
  end

  def self.down
    throw IrreversibleMigrationException.new
  end
end
