class IpAddress < ActiveRecord::Base
  attr_accessible :address, :device_id, :netmask, :status
end
