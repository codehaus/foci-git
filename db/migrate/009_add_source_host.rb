class AddSourceHost < ActiveRecord::Migration

  def self.up
    add_column :sources, :host, :string, :null => true
    add_column :sources, :name, :string, :null => true
    
    Source.connection.execute("CREATE UNIQUE INDEX SOURCES_HOST_NAME_UK ON SOURCES(HOST, NAME)")
    Source.connection.execute("DROP INDEX SOURCES_URL_UK")
    Source.connection.execute("CREATE UNIQUE INDEX SOURCES_HOST_URL_UK ON SOURCES(HOST, URL)")

    handlers = []
    handlers << Foci::Handlers::BzipHandler.new
    handlers << Foci::Handlers::GzipHandler.new
    handlers << Foci::Handlers::RawHandler.new

    Source.find(:all).each { |source|
      for handler in handlers
        if handler.will_handle?(source.url)
          source.host = 'codehaus03.managed.contegix.com'
          source.name = handler.name(source.url)
          source.save!
          break
        end
      end
    }
    change_column :sources, :host, :string, :null => false
  end

  def self.down
  end
end
