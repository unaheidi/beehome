module Business
  class ProduceContainer
    attr_reader :purpose, :options, :available_device, :recommended_image, :free_ip_address, :cpu_set

    include Utils::Logger
    include Utils::Time

    def initialize(purpose,options = {processor_size: 0, processor_occupy_mode: 'share', memory_size: 2})
      @purpose = purpose
      @options = options
      if purpose == 'jagent'
        options[:processor_occupy_mode] = 'private'
        options[:processor_size] = 2
        options[:memory_size] = 4
      end

      if purpose == 'alpha'
        options[:memory_size] = 2
      end

      self.logger_file = logger_file_name
    end

    def execute
      @available_device = Device.available_device(purpose, options)
      @recommended_image = Image.recommended_image(purpose)
      return {"result" => false, "message" => "[warning] No available device."} unless available_device
      return {"result" => false, "message" => "[warning] No recommended image."} unless recommended_image
      @free_ip_address = IpAddress.free_ip_address(available_device.id)
      return {"result" => false, "message" => "[warning] No free ip."} unless free_ip_address
      begin
        free_ip_address.update_attributes(status: IpAddress::STATUS_LIST['used'])
        request = Service::Docker::Request.new(docker_remote_api: available_device.docker_remote_api)
        request.create_image(fromImage: recommended_image.repository, tag:recommended_image.tag)
        result = request.create_container(purpose, container_params)
        @container_id = result.to_hash["Id"]
        start_status = request.start_container(container: @container_id).response.code if @container_id

        if @container_id && start_status == "204"
          update_db_status
          create_container_record if @container_id
          {"result" => true, "message" => "[info] Produce a container successfully.", "ip" => free_ip_address.address, "container_id" => @container_id}
        else
          free_ip_address.update_attributes(status: IpAddress::STATUS_LIST['free'])
          request.delete_container(container: @container_id) if @container_id
          logger.error("Produce container failed, error message: unknown." +
                       " #{purpose}:#{options[:processor_size]}cpu_#{options[:processor_occupy_mode]}_#{options[:memory_size]}G memory." +
                       "Please check the #{available_device.ip} device!")
          {"result" => false, "message" => "[error] unknown."}
        end
      rescue => e
        free_ip_address.update_attributes(status: IpAddress::STATUS_LIST['free'])
        request.delete_container(container: @container_id) if @container_id
        logger.error("Produce container failed, error message: #{e}." +
                     " #{purpose}:#{options[:processor_size]}cpu_#{options[:processor_occupy_mode]}_#{options[:memory_size]}G memory." +
                     "Please check the #{available_device.ip} device!")
        {"result" => false, "message" => "[error] #{e}."}
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
      ip = free_ip_address.address + '/' +
            free_ip_address.netmask + '@' +
              free_ip_address.device.gateway
      image = recommended_image.repository + ':' + recommended_image.tag
      memory_size = options[:memory_size] * 1024 * 1024 * 1024

      if purpose == 'alpha'
        return { ip: ip, image: image, memory_size:  memory_size}
      end

      if purpose == 'jagent'
        @cpu_set = available_device.free_processor_set.slice(0,2).join(',')
        return { ip: ip, image: image, memory_size: memory_size, cpu_set: cpu_set }
      end

      if purpose == 'performance_test' && options[:processor_occupy_mode] == "private"
        @cpu_set = available_device.free_processor_set.slice(0,options[:processor_size]).join(',')
        return { ip: ip, image: image, memory_size: memory_size, cpu_set:  cpu_set }
      end

      if purpose == 'performance_test' && options[:processor_occupy_mode] == "share"
        @cpu_set = available_device.share_free_processor_set_string(options[:processor_size])
        return { ip: ip, image: image, memory_size: memory_size, cpu_set:  cpu_set }
      end
    end

    def logger_file_name
      @logger_file_name = "produce_container/#{purpose}.log"
    end

  end
end