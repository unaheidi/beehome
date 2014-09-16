class IpAddress < ActiveRecord::Base
  attr_accessible :address, :device_id, :netmask, :status

  belongs_to :device

  scope :free, -> { where "status in (0)" }

  STATUS_LIST = {'free' => 0, 'used' => 1}

  state_machine :status, :initial => :free do
    state :free,         :value => 0
    state :used,         :value => 1
  end

  class << self
    def free_ip_address(available_device_id)
      @free_ip_address ||=
        begin
          IpAddress.free.where(device_id: available_device_id).first
        rescue
          nil
        end
    end
  end

end
