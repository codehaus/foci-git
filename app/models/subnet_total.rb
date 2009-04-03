class SubnetTotal < ActiveRecord::Base
  belongs_to :vhost
  belongs_to :period
  belongs_to :subnet

  def to_s
    "SubnetTotal[id=#{id},vhost=#{vhost},period=#{period},subnet=#{subnet}]"
  end
  
  def self.exec_aggregate_subnet_total
    log("Linking sources to periods")
    StoredProc.exec('sp_aggregate_subnet_total()')
  end

private
  def self.log(msg)
    puts msg
  end

  
end
