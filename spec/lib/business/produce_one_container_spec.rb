require 'rails_helper'

RSpec.describe Device, :type => :model do
  describe "whether can create all containers with specified requirements." do
    before :each do
      create(:performance_v1_3, status: 2)
      @device_1= create(:device)
      @device_2= create(:device,ip: "192.168.124.5")
      @device_3= create(:device,ip: "192.168.124.6")

      @ip_11 = create(:ip_address,
        device: @device_1,
        address: "192.168.123.100"
      )
      @ip_12 = create(:ip_address,
        device: @device_1,
        address: "192.168.123.101"
      )
      @ip_13  = create(:ip_address,
        device: @device_1,
        address: "192.168.123.102"
      )
      @ip_14  = create(:ip_address,
        device: @device_1,
        address: "192.168.123.103"
      )
      @ip_15  = create(:ip_address,
        device: @device_1,
        address: "192.168.123.104"
      )
      @ip_16  = create(:ip_address,
        device: @device_1,
        address: "192.168.123.105"
      )
      @ip_21 = create(:ip_address,
        device: @device_2,
        address: "192.168.124.200"
      )
      @ip_22 = create(:ip_address,
        device: @device_2,
        address: "192.168.124.201"
      )
      @ip_23 = create(:ip_address,
        device: @device_2,
        address: "192.168.124.202"
      )
      @ip_24 = create(:ip_address,
        device: @device_2,
        address: "192.168.124.203"
      )
      @ip_31 = create(:ip_address,
        device: @device_3,
        address: "192.168.124.220"
      )
      @ip_32 = create(:ip_address,
        device: @device_3,
        address: "192.168.124.221"
      )
      @ip_33 = create(:ip_address,
        device: @device_3,
        address: "192.168.124.222"
      )
      @container_11 = create(:container_private,
        ip_address: @ip_11,
        image: create(:performance_v1_3),
        cpu_set: "0,1,2,3",
        memory_size: 24,
        processor_size: 4
      )
      @container_12 = create(:container_private,
        ip_address: @ip_12,
        image: create(:performance_v1_3),
        cpu_set: "4,5,6,7,8,9",
        memory_size: 16,
        processor_size: 6
      )
    end

    it "hold resource" do
      produce_one_container = Business::ProduceOneContainer.new("performance_test",
        {processor_size: 4, processor_occupy_mode: 'private', memory_size: 4})
      expect(produce_one_container.hold_resource).to eq true
    end

    it "provide resources for a few containers" do
      produce_1_container = Business::ProduceOneContainer.new("performance_test",
        options = {processor_size: 4, processor_occupy_mode: 'private', memory_size: 4})
      expect(produce_1_container.hold_resource).to eq true

      produce_2_container = Business::ProduceOneContainer.new("performance_test",
        options = {processor_size: 2, processor_occupy_mode: 'private', memory_size: 4})
      expect(produce_2_container.hold_resource).to eq true

      produce_3_container = Business::ProduceOneContainer.new("performance_test",
        options = {processor_size: 2, processor_occupy_mode: 'private', memory_size: 4})
      expect(produce_3_container.hold_resource).to eq true

      produce_4_container = Business::ProduceOneContainer.new("performance_test",
        options = {processor_size: 8, processor_occupy_mode: 'private', memory_size: 4})
      expect(produce_4_container.hold_resource).to eq true

      produce_5_container = Business::ProduceOneContainer.new("performance_test",
        options = {processor_size: 9, processor_occupy_mode: 'private', memory_size: 4})
      expect(produce_5_container.hold_resource).to eq true

      produce_6_container = Business::ProduceOneContainer.new("performance_test",
        options = {processor_size: 6, processor_occupy_mode: 'private', memory_size: 4})
      expect(produce_6_container.hold_resource).to eq true

      produce_7_container = Business::ProduceOneContainer.new("performance_test",
        options = {processor_size: 7, processor_occupy_mode: 'private', memory_size: 4})
      expect(produce_7_container.hold_resource).to eq true

      produce_8_container = Business::ProduceOneContainer.new("performance_test",
        options = {processor_size: 1, processor_occupy_mode: 'private', memory_size: 4})
      expect(produce_8_container.hold_resource).to eq false
    end







  end
end
