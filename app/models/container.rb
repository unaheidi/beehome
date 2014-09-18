class Container < ActiveRecord::Base
  attr_accessible :container_id, :image_id, :ip_address_id, :status

  belongs_to :image
  belongs_to :ip_address

  STATUS_LIST = {'available' => 0, 'used' => 1, 'deleted' => 2}

  class << self
    def to_be_deleted_container(container_id)
      Container.where(container_id: container_id).first
    end
  end
end
