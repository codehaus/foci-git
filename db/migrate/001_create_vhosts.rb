class CreateVhosts < ActiveRecord::Migration
  def self.up
    create_table :vhosts do |t|
      t.column :host, :string, :null => false, :unique=>true
      t.column :parent_id, :integer, :null => true
      t.column :aggregate_paths, :boolean, :null => false, :default => false
    end
    
    Vhost.new(:host => 'codehaus.org', :aggregate_paths => true).save
    Vhost.new(:host => 'rubyhaus.org', :aggregate_paths => true).save
    Vhost.new(:host => 'dist.codehaus.org', :aggregate_paths => true).save
    Vhost.new(:host => 'fisheye.codehaus.org', :aggregate_paths => false).save
    Vhost.new(:host => 'fisheye.rubyhaus.org', :aggregate_paths => false).save

    Vhost.connection.execute("CREATE UNIQUE INDEX VHOSTS_HOST_UK ON VHOSTS(HOST)")
      
  end

  def self.down
    drop_table :vhosts
  end
end
