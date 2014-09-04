class Image < ActiveRecord::Base
  attr_accessible :dockerfile_url, :image_id, :repository, :status, :tag, :type
end
