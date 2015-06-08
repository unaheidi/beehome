require 'rails_helper'

RSpec.describe Device, :type => :model do
  describe "whether can provide required cpu-set and memory." do
    before :each do
      @device = create(:device)
      @ip_01 = create(:ip_address,
        device: @device,
        address: "192.168.123.1"
      )
      @ip_02 = create(:ip_address,
        device: @device,
         address: "192.168.123.2"
      )
      @container_01 = create(:container_private,
        ip_address: @ip_01,
        image: create(:performance_v1_3),
        cpu_set: "0,1,2,3",
        memory_size: 24,
        processor_size: 4
      )
      @container_02 = create(:container_private,
        ip_address: @ip_02,
        image: create(:performance_v1_3),
        cpu_set: "4,5,6,7,8,9",
        memory_size: 32,
        processor_size: 6
      )
    end

    it "returns living containers" do
      expect(@device.living_containers).to eq [@container_01, @container_02]
    end

    it "free processor set" do
      expect(@device.free_processor_set).to eq [10,11,12,13,14,15]
    end

    it "free memory" do
      expect(@device.free_memory).to eq @device.memory_size - (24 + 32)
    end

    it "can satisfy private case" do
      purpose = "performance_test"
      options = {processor_size: 4, processor_occupy_mode: 'private', memory_size: 4}
      expect(@device.can_satisfied?(purpose, options)).to eq true

      purpose = "performance_test"
      options = {processor_size: 4, processor_occupy_mode: 'private', memory_size: 24}
      expect(@device.can_satisfied?(purpose, options)).to eq false
    end

    it "share free processor set string" do
      ip = create(:ip_address,
        device: @device,
        address: "192.168.123.3"
      )
      container = create(:container_share,
        ip_address: ip,
        image: create(:performance_v1_3),
        cpu_set: "10,11,12,13",
        memory_size: 2,
        processor_size: 4
      )
      expect(@device.living_containers.where(processor_occupy_mode: "share").first).to eq container
      expect(@device.free_processor_set).to eq [14,15]
      expect(@device.share_free_processor_set_string(5)).to eq ""
      expect(@device.share_free_processor_set_string(2)).to eq "14,15"
      expect(@device.share_free_processor_set_string(4)).to eq "10,11,12,13"

      purpose = "performance_test"
      options = {processor_size: 2, processor_occupy_mode: 'share', memory_size: 4}
      expect(@device.can_satisfied?(purpose, options)).to eq true

      purpose = "performance_test"
      options = {processor_size: 4, processor_occupy_mode: 'share', memory_size: 4}
      expect(@device.can_satisfied?(purpose, options)).to eq true

      purpose = "performance_test"
      options = {processor_size: 3, processor_occupy_mode: 'share', memory_size: 4}
      expect(@device.can_satisfied?(purpose, options)).to eq false

    end

  end
end
