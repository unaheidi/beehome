class IpAddress < ActiveRecord::Base
  attr_accessible :address, :device_id, :netmask, :status

  STATUS_LIST = {'free' => 0, 'used' => 1}
end
