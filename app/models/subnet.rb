class Subnet < ActiveRecord::Base
  def to_s
    "Subnet[id=#{id},address=#{address}]"
  end
end
