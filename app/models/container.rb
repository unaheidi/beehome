class Container < ActiveRecord::Base
  attr_accessible :container_id, :image_id, :ip_address_id, :status,
                  :cpu_set, :processor_size, :processor_occupy_mode, :memory_size

  belongs_to :image
  belongs_to :ip_address

  scope :living, -> { where "status in (0,1)" }
  scope :alpha, -> { where(image_id: Image.alpha.pluck(:id)) }
  scope :performance_test, -> { where(image_id: Image.performance_test.pluck(:id)) }

  STATUS_LIST = {'available' => 0, 'used' => 1, 'deleted' => 2}

  def purpose
    self.image.purpose
  end

  class << self
    def to_be_deleted_container(container_id)
      Container.where(container_id: container_id).first
    end
  end
end
