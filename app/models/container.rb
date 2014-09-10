class Container < ActiveRecord::Base
  attr_accessible :container_id, :image_id, :ip_address_id, :status

  belongs_to :image
  belongs_to :ip_address

  STATUS_LIST = {'available' => 0, 'used' => 1, 'deleted' => 2}
end
