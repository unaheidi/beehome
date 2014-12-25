module Business
	class DeleteContainer
    attr_reader :options, :to_be_deleted_container

    include Utils::Logger
    include Utils::Time

    def initialize(options = {container_id: "0efettttttt"})
      @options = options
      self.logger_file = logger_file_name
    end

    def execute
      @to_be_deleted_container = Container.to_be_deleted_container(options[:container_id])
      return {"result" => false,"message" => "[warning] The container once was deleted before."} if to_be_deleted_container.status == Container::STATUS_LIST['deleted']
      return {"result" => false,"message" => "[warning] The container to be deleted doesn't exist."} unless to_be_deleted_container
      begin
        request = Service::Docker::Request.new(docker_remote_api: to_be_deleted_container.ip_address.device.docker_remote_api)
        request.delete_container(container: to_be_deleted_container.container_id)
        to_be_deleted_container.update_attributes(status: Container::STATUS_LIST['deleted'])
        update_db_status
        {"result" => true,"ip" => to_be_deleted_container.ip_address.address}
      rescue => e
        logger.error("Delete container failed, error message: #{e}.container_id: #{to_be_deleted_container.container_id}.")
        {"result" => false, "message" => e}
      end
    end

    def update_db_status
      to_be_deleted_container.ip_address.update_attributes(status: IpAddress::STATUS_LIST['free'])
      if to_be_deleted_container.ip_address.device.status == Device::STATUS_LIST['full']
        to_be_deleted_container.ip_address.device.update_status('available')
      end
    end

    def logger_file_name
      @logger_file_name = "delete_container/all.log"
    end

  end
end