class IpAddress < ActiveRecord::Base
  attr_accessible :address, :device_id, :netmask, :status

  STATUS_LIST = {'free' => 0, 'used' => 1}

  state_machine :status, :initial => :free do
    state :free,         :value => 0  
    state :used,         :value => 1
  end
end
