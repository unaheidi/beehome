class Image < ActiveRecord::Base
  attr_accessible :dockerfile_url, :image_id, :repository, :status, :tag, :purpose

  STATUS_LIST = {'discarded' => 0, 'available' => 1, 'recommended' => 2}


  state_machine :status, :initial => :available do
    state :discarded,         :value => 0  
    state :available,         :value => 1    
    state :recommended,       :value => 2
  end
end
