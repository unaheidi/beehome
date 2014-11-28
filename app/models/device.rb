class Device < ActiveRecord::Base
  attr_accessible :docker_remote_api, :ip, :os, :status, :gateway,
                  :processor_size, :memory_size, :purpose

  validates_uniqueness_of :ip

  has_many :ip_addresses, dependent: :destroy

  scope :unavailable, -> { where "status in (0,1)" }

  STATUS_LIST = {'bad' => 0, 'full' => 1, 'available' => 2}

  state_machine :status, :initial => :available do
    state :bad,           :value => 0
    state :full,          :value => 1
    state :available,     :value => 2
  end

  def update_status(status)
    self.status = Device::STATUS_LIST[status] unless Device::STATUS_LIST[status].nil?
    self.save
  end

  def can_satisfied?(purpose = 'performance_test',
                     options = {processor_size: 4, processor_occupy_mode: 'private', memory_size: 4}
                    )
    return false if options[:memory_size] > free_memory
    return false if options[:processor_occupy_mode] == "private" &&
                    free_processor_set.size < options[:processor_size]
    return false if options[:processor_occupy_mode] == "share" &&
                    share_free_processor_set_string(options[:processor_size]).blank?
    return true
  end

  def living_containers
    Container.living.where(ip_address_id: IpAddress.where(device_id: self.id).pluck(:id))
  end

  def free_processor_set
    (0..self.processor_size - 1).to_a -
      living_containers.pluck(:cpu_set).uniq.join(',').split(',').map(&:to_i)
  end

  def free_memory
    used_memory = living_containers.pluck(:memory_size).reduce :+
    self.memory_size - used_memory
  end

  def share_free_processor_set_string(processor_size)
    result = living_containers.
              where(processor_occupy_mode: "share").
              where(processor_size: processor_size).
              group(:cpu_set).count(:cpu_set).select{|k,v| v < processor_size }.first
    return result[0] if result
    return free_processor_set.slice(0, processor_size).join(',')
  end

  class << self
    def available_device(purpose,
                         options = {processor_size: 4, processor_occupy_mode: 'private', memory_size: 4}
                        )
      if purpose == "alpha"
        Device.where(purpose: purpose).where(status: Device::STATUS_LIST['available']).first
      else
        satisfied_device(purpose, options)
      end
    end

    def satisfied_device(purpose,options)
      filted_devices = Device.where(purpose: purpose).where(status: Device::STATUS_LIST['available'])
      filted_devices.select{|device| device.can_satisfied?(purpose, options)}.first
    end
  end
end
