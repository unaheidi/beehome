class Image < ActiveRecord::Base
  attr_accessible :dockerfile_url, :image_id, :repository, :status, :tag, :purpose

  validate :validate_one_recommended_for_a_purpose, :on => :create
  validate :validate_image_id_correct, :on => :create

  scope :recommended, -> { where(status: Image::STATUS_LIST['recommended']) }
  scope :alpha, -> { where(purpose: "alpha") }
  scope :performance_test, -> { where(purpose: "performance_test") }

  STATUS_LIST = {'discarded' => 0, 'available' => 1, 'recommended' => 2}

  state_machine :status, :initial => :available do
    state :discarded,         :value => 0
    state :available,         :value => 1
    state :recommended,       :value => 2
  end

  def validate_one_recommended_for_a_purpose
    if status == Image::STATUS_LIST['recommended'] && self.class.exists?(purpose: purpose, status: Image::STATUS_LIST['recommended'])
      errors.add(:base, "There is a recommended image for #{} purpose.")
    end
  end

  def validate_image_id_correct
    image = self.class.where(repository: repository, tag: tag).first
    if !image.blank? && image.image_id != image_id
      errors.add(:base, "The same repositorie with same tag should have the same image_id.")
    end
  end

  class << self
    def recommended_image(purpose)
      Image.recommended.where(purpose: purpose).first
    end
  end
end
