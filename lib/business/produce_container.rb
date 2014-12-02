module Business
	class ProduceContainer
    attr_reader :purpose, :options, :available_device, :recommended_image, :free_ip_address, :cpu_set
    def initialize(purpose,options = {processor_size: 0, processor_occupy_mode: 'share', memory_size: 2})
      @purpose = purpose
      @options = options
    end

    def execute
      @available_device = Device.available_device(purpose, options)
      @recommended_image = Image.recommended_image(purpose)
      return [false, "[warning] No available device."] unless available_device
      return [false, "[warning] No recommended image."] unless recommended_image
      @free_ip_address = IpAddress.free_ip_address(available_device.id)
      return [false, "[warning] No free ip."] unless free_ip_address
      begin
        request = Service::Docker::Request.new(docker_remote_api: available_device.docker_remote_api)
        request.create_image(fromImage: recommended_image.repository, tag:recommended_image.tag)
        debugger
        result = request.create_container(purpose, container_params)
        @container_id = result.to_hash["Id"]
        request.start_container(container: @container_id)
        update_db_status
        create_container_record
        [true, "[info] Produce a container successfully.", free_ip_address.address, @container_id]
      rescue => e
        [false, "[error] #{e}.#{result}."]
      end
    end

    def update_db_status
      free_ip_address.update_attributes(status: IpAddress::STATUS_LIST['used'])
      if available_device.ip_addresses.free.size == 0
        available_device.update_status('full')
      end
    end

    def create_container_record
      container = {
        container_id: @container_id,
        image_id: recommended_image.id,
        ip_address_id: free_ip_address.id,
        cpu_set: cpu_set,
        processor_size: options[:processor_size],
        processor_occupy_mode: options[:processor_occupy_mode],
        memory_size: options[:memory_size],
        status: Container::STATUS_LIST['available'],
      }
      Container.create(container)
    end

    def container_params
      if purpose == 'alpha'
        { ip: free_ip_address.address + '/' + free_ip_address.netmask + '@' + free_ip_address.device.gateway,
          image: recommended_image.repository + ':' + recommended_image.tag,
          memory_size:  2147483648,
        }
      elsif purpose == 'performance_test' && options[:processor_occupy_mode] == "private"
        @cpu_set = available_device.free_processor_set.slice(0,options[:processor_size]).join(',')
        { ip: free_ip_address.address + '/' +
              free_ip_address.netmask + '@' +
              free_ip_address.device.gateway,
          image: recommended_image.repository + ':' + recommended_image.tag,
          memory_size: options[:memory_size] * 1024 * 1024 * 1024,
          cpu_set:  cpu_set,
        }
      elsif purpose == 'performance_test' && options[:processor_occupy_mode] == "share"
        @cpu_set = available_device.share_free_processor_set_string(options[:processor_size])
        { ip: free_ip_address.address + '/' +
              free_ip_address.netmask + '@' +
              free_ip_address.device.gateway,
          image: recommended_image.repository + ':' + recommended_image.tag,
          memory_size: options[:memory_size] * 1024 * 1024 * 1024,
          cpu_set:  cpu_set,
        }
      end
    end

	end
end