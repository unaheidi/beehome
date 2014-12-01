module Business
	class DeleteContainer
    attr_reader :options, :to_be_deleted_container
    def initialize(options = {container_id: "0efettttttt"})
      @options = options
    end

    def execute
      @to_be_deleted_container = Container.to_be_deleted_container(options[:container_id])
      return [false,"[warning] The container once was deleted before."] if to_be_deleted_container.status == Container::STATUS_LIST['deleted']
      return [false,"[warning] The container to be deleted doesn't exist."] unless to_be_deleted_container
      to_be_deleted_container.update_attributes(status: Container::STATUS_LIST['deleted'])
      begin
        request = Service::Docker::Request.new(docker_remote_api: to_be_deleted_container.ip_address.device.docker_remote_api)
        request.delete_container(container: to_be_deleted_container.container_id)
        update_db_status
        [true,to_be_deleted_container.ip_address.address]
      rescue => e
        [false,e]
      end
    end

    def update_db_status
      to_be_deleted_container.ip_address.update_attributes(status: IpAddress::STATUS_LIST['free'])
      if to_be_deleted_container.ip_address.device.status == Device::STATUS_LIST['full']
        to_be_deleted_container.ip_address.device.update_status('available')
      end
    end

  end
end