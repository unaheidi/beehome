module Business
	class RebuildContainer
    attr_reader :options, :recommended_image, :to_be_deleted_container


    def initialize(options = {container_id: "0efettttttt"})
      @options = options
    end

    def execute
      @to_be_deleted_container = Container.to_be_deleted_container(options[:container_id])
      return {"result" => false, "message" => "[warning] The container to be deleted doesn't exist."} unless to_be_deleted_container
      to_be_deleted_container.update_attributes(status: Container::STATUS_LIST['deleted'])
      @recommended_image = Image.recommended_image(to_be_deleted_container.image.purpose)
      return {"result" => false, "message" => "[warning] There's none recommended image for #{to_be_deleted_container.image.purpose} purpose."} unless recommended_image
      begin
        request = Service::Docker::Request.new(docker_remote_api: to_be_deleted_container.ip_address.device.docker_remote_api)
        request.delete_container(container: to_be_deleted_container.container_id)
        request.create_image(fromImage: recommended_image.repository, tag:recommended_image.tag)
        result = request.create_container(to_be_deleted_container.image.purpose,container_params)
        @container_id = result.to_hash["Id"]
        request.start_container(container: @container_id)
        create_container_record
        {"result" => true, "message" => to_be_deleted_container.ip_address.address}
      rescue => e
        {"result" => false, "message" => e}
      end
    end

    def create_container_record
      container = {
        container_id: @container_id,
        image_id: recommended_image.id,
        ip_address_id: to_be_deleted_container.ip_address_id,
        cpu_set: to_be_deleted_container.cpu_set,
        processor_size: to_be_deleted_container.processor_size,
        processor_occupy_mode: to_be_deleted_container.processor_occupy_mode,
        memory_size: to_be_deleted_container.memory_size,
        status: Container::STATUS_LIST['available'],
      }
      Container.create(container)
    end

    def container_params
      if to_be_deleted_container.image.purpose == 'alpha'
        { ip: to_be_deleted_container.ip_address.address + '/' +
              to_be_deleted_container.ip_address.netmask + '@' +
              to_be_deleted_container.ip_address.device.gateway,
          image: recommended_image.repository + ':' + recommended_image.tag,
          memory_size:  2147483648,
        }
      else
        { ip: to_be_deleted_container.ip_address.address + '/' +
              to_be_deleted_container.ip_address.netmask + '@' +
              to_be_deleted_container.ip_address.device.gateway,
          image: recommended_image.repository + ':' + recommended_image.tag,
          memory_size: to_be_deleted_container.memory_size * 1024 * 1024 * 1024,
          cpu_set:  to_be_deleted_container.cpu_set,
        }
      end
    end

  end
end