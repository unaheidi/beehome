class Device < ActiveRecord::Base
  attr_accessible :docker_remote_api, :ip, :os, :status, :gateway

  validates_uniqueness_of :ip

  has_many :ip_addresses, dependent: :destroy

  scope :unavailable, -> { where "status in (0,1)" }

  STATUS_LIST = {'bad' => 0, 'full' => 1, 'available' => 2}

  state_machine :status, :initial => :available do
    state :bad,           :value => 0
    state :full,          :value => 1
    state :available,     :value => 2
  end

  class << self
    def available_device
      @available_device ||=
        begin
          Device.where(status: Device::STATUS_LIST['available']).first
        rescue
          nil
        end
    end
  end
end
