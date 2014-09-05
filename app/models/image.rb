class Image < ActiveRecord::Base
  attr_accessible :dockerfile_url, :image_id, :repository, :status, :tag, :purpose

  STATUS_LIST = {'discarded' => 0, 'available' => 1, 'recommended' => 2}
end
