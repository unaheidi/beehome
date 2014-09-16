module Business
	class RebuildContainer
    attr_reader :options, :recommended_image
    def initialize(options = {container_id: "0efettttttt"})
      @options = options
    end

    def execute
      to_be_deleted_container.update_attributes(status: Container::STATUS_LIST['deleted'])
      @recommended_image = Image.recommended_image(to_be_deleted_container.image.purpose)
      begin
        request = Service::Docker::Request.new(docker_remote_api: to_be_deleted_container.ip_address.device.docker_remote_api)
        request.delete_container(container: to_be_deleted_container.container_id)
        request.create_image(fromImage: recommended_image.repository, tag:recommended_image.tag)
        result = request.create_container(ip: to_be_deleted_container.ip_address.address + '/' + to_be_deleted_container.ip_address.netmask + '@' + to_be_deleted_container.ip_address.device.gateway,
                                          image: recommended_image.repository + ':' + recommended_image.tag)
        @container_id = result.to_hash["Id"]
        request.start_container(container: @container_id)
        create_container_record
        puts @container_id
      rescue => e

      end
    end

    def to_be_deleted_container
      @to_be_deleted_container ||=
        begin
          Container.where(container_id: options[:container_id]).first
        rescue
          nil
        end
    end

    def create_container_record
      container = {
        container_id: @container_id,
        image_id: recommended_image.id,
        ip_address_id: to_be_deleted_container.ip_address_id,
        status: Container::STATUS_LIST['available'],
      }
      Container.create(container)
    end

  end
end