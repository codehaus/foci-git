class Foci::Aggregators::Aggregator
  def logger=(logger)
    raise Exception.new("Please handle the setting of a logger in #{self.class.name}")
  end
end
