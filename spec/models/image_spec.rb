require 'rails_helper'

RSpec.describe Image, :type => :model do
  it "is invalid with more than one recommended images for some purpose" do
    create(:alpha_v1_1, status: 2)
    image = build(:alpha_v1_2, status: 2)
    image.valid?
    expect(image.errors[:base]).to include("There is a recommended image for alpha.")
  end

  it "is invalid that two images have the same repository and tag,but have different image_id" do
    create(:alpha_v1_1, image_id: "77c447941689")
    image = build(:alpha_v1_1, image_id: "3422423FFE12")
    image.valid?
    expect(image.errors[:base]).to include("The same repositories with same tag should have the same image_id.")
  end

  it "return the recommended image for one purpose with status=2" do
    create(:performance_v1_3, status: 2)
    create(:alpha_v1_0, status: 1)
    create(:alpha_v1_1, status: 1)
    image_alpha = create(:alpha_v1_2, status: 2)
    expect(Image.recommended_image("alpha")).to eq image_alpha
  end

end
