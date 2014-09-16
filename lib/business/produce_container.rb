module Business
	class ProduceContainer
    attr_reader :options, :available_device, :recommended_image
    def initialize(options = {purpose: 'alpha'})
      @options = options
    end

    def execute
      @available_device = Device.available_device
      @recommended_image = Image.recommended_image(options[:purpose])
      return "[warning] No available device." unless available_device
      return "[warning] No recommended image." unless recommended_image

      begin
        request = Service::Docker::Request.new(docker_remote_api: available_device.docker_remote_api)
        request.create_image(fromImage: recommended_image.repository, tag:recommended_image.tag)
        result = request.create_container(ip: free_ip_address.address + '/' + free_ip_address.netmask + '@' + free_ip_address.device.gateway,
                                             image: recommended_image.repository + ':' + recommended_image.tag)
        @container_id = result.to_hash["Id"]
        request.start_container(container: @container_id)
        update_db_status
        create_container_record
        "[info] Produce a container successfully."
      rescue => e
        "[error] #{e}.#{result}."
      end
    end

    def free_ip_address
    	@free_ip_address ||=
        begin
    		  IpAddress.where(device_id: available_device.id, status: IpAddress::STATUS_LIST['free']).first
        rescue
          nil
        end
    end

    def update_db_status
      free_ip_address.update_attributes(status: IpAddress::STATUS_LIST['used'])
      if available_device.ip_addresses.free.size == 0
        available_device.update_attributes(status: Device::STATUS_LIST['full'])
      end
    end

    def create_container_record
      container = {
        container_id: @container_id,
        image_id: recommended_image.id,
        ip_address_id: free_ip_address.id,
        status: Container::STATUS_LIST['available'],
      }
      Container.create(container)
    end

	end
end