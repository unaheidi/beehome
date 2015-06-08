module Business
  class ProduceOneContainer
    attr_reader :purpose, :options, :available_device, :recommended_image,
                :free_ip_address, :cpu_set, :new_container, :specified_ip

    include Utils::Logger
    include Utils::Time

    def initialize(purpose, options = {processor_size: 0, processor_occupy_mode: 'share', memory_size: 2}, specified_ip = nil)
      @purpose = purpose
      @specified_ip = specified_ip
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
      pre_check_result = hold_resource
      if !pre_check_result && !recommended_image
        return {"result" => false, "message" => "[warning] No recommended image."}
      end

      if !pre_check_result && !@specified_ip.blank?
        return {"result" => false, "message" => "[warning] The specified ip can not be used to produce new container."}
      end

      return {"result" => false, "message" => "[warning] No available device."} unless available_device
      return {"result" => false, "message" => "[warning] No free ip."} unless free_ip_address
      begin
        request = Service::Docker::Request.new(docker_remote_api: available_device.docker_remote_api)
        request.create_image(fromImage: recommended_image.repository, tag:recommended_image.tag)
        result = request.create_container(purpose, container_params)
        @container_id = result.to_hash["Id"]
        start_status = request.start_container(container: @container_id) if @container_id

        if @container_id && start_status == "204"
          new_container.update_attributes(container_id: @container_id)
          {"result" => true, "message" => "[info] Produce a container successfully.", "ip" => free_ip_address.address, "container_id" => @container_id}
        else
          release_resource
          request.delete_container(container: @container_id) if @container_id
          logger.error("Produce container failed, error message: unknown." +
                       " #{purpose}:#{options[:processor_size]}cpu_#{options[:processor_occupy_mode]}_#{options[:memory_size]}G memory." +
                       "Please check the #{available_device.ip} device!")
          {"result" => false, "message" => "[error] unknown."}
        end
      rescue => e
        release_resource
        request.delete_container(container: @container_id) if @container_id
        logger.error("Produce container failed, error message: #{e}." +
                     " #{purpose}:#{options[:processor_size]}cpu_#{options[:processor_occupy_mode]}_#{options[:memory_size]}G memory." +
                     "Please check the #{available_device.ip} device!")
        {"result" => false, "message" => "[error] #{e}."}
      end
    end

    def hold_resource
      @recommended_image = Image.recommended_image(purpose)
      return false unless recommended_image

      if !@specified_ip.blank? && !specified_ip_available?
        return false
      end

      if !@specified_ip.blank? && specified_ip_available?
        @available_device = IpAddress.where(address: @specified_ip).first.device
        @free_ip_address = IpAddress.where(address: @specified_ip).first
      end

      if @specified_ip.blank?
        @available_device = Device.available_device(purpose, options)
        return false unless available_device
        @free_ip_address = IpAddress.free_ip_address(available_device.id)
        return false unless free_ip_address
      end

      update_db_status("hold")
      get_cpu_set
      create_container_record
      return true
    end

    def release_resource
      update_db_status("release")
      new_container.destroy if new_container
    end

    def update_db_status(reason)
      ip_status = reason == "hold" ? IpAddress::STATUS_LIST['used'] : IpAddress::STATUS_LIST['free']
      free_ip_address.update_attributes(status: ip_status)
      if reason == "hold" && available_device.ip_addresses.free.size == 0
        available_device.update_status('full')
      end
      if reason == "release"
        available_device.update_status('available')
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
      Rails.logger.info("create container: #{container}")
      @new_container = Container.create(container)
    end

    def get_cpu_set
      if purpose == 'jagent'
        @cpu_set = available_device.free_processor_set.slice(0,2).join(',')
      end

      if purpose == 'performance_test' && options[:processor_occupy_mode] == "private"
        @cpu_set = available_device.free_processor_set.slice(0,options[:processor_size]).join(',')
      end

      if purpose == 'performance_test' && options[:processor_occupy_mode] == "share"
        @cpu_set = available_device.share_free_processor_set_string(options[:processor_size])
      end
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
      Rails.logger.info("container_params : #{ip}; #{image}; #{memory_size}, cpu_set: #{@cpu_set}")
      return { ip: ip, image: image, memory_size: memory_size, cpu_set:  @cpu_set }
    end

    def specified_ip_available?
      specified_ip_address = IpAddress.where(address: @specified_ip).first

      if specified_ip_address.nil?
        return false
      end

      if specified_ip_address.device.nil? || specified_ip_address.device.docker_remote_api.nil?
        return false
      end

      options = {docker_remote_api: specified_ip_address.device.docker_remote_api}

      if Service::Docker::Request.new(options).container_with_some_ip_exist?( @specified_ip )
        return false
      else
        Container.clean_with_specified_ip(@specified_ip)
        return true
      end

      false
    end

    def logger_file_name
      @logger_file_name = "produce_container/#{purpose}.log"
    end

  end
end
