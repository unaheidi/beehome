class Container < ActiveRecord::Base
  attr_accessible :container_id, :image_id, :ip_address_id, :status,
                  :cpu_set, :processor_size, :processor_occupy_mode, :memory_size

  belongs_to :image
  belongs_to :ip_address

  scope :living, -> { where "status in (0,1)" }
  scope :purpose, ->(purpose) { where(image_id: Image.purpose(purpose).pluck(:id)) }

  STATUS_LIST = {'available' => 0, 'used' => 1, 'deleted' => 2}

  def purpose
    self.image.purpose
  end

  class << self
    def to_be_deleted_container(container_id)
      Container.where(container_id: container_id).first
    end

    def clean_with_specified_ip(ip)
      return false if ip.blank?
      containers = Container.where(ip_address_id: IpAddress.where(address: ip).first.id)
      containers.each do |container|
        container.update_attributes(status: Container::STATUS_LIST['deleted'])
      end
      return true
    end
  end
end
