class Device < ActiveRecord::Base
  attr_accessible :docker_remote_api, :ip, :os, :status, :gateway

  has_many :ip_addresses, dependent: :destroy

  scope :unavailable, -> { where "status in (0,1)" }

  STATUS_LIST = {'bad' => 0, 'full' => 1, 'available' => 2}
end
