module Business
  class ProduceContainers
    attr_reader :purpose, :machines
    include Utils::Logger
    include Utils::Time

    def initialize(purpose, machines)
      @purpose = purpose
      @machines = machines
      self.logger_file = logger_file_name
    end

    def execute
      last_result = true
      produced_containers = []
      message = []

      @machines.each do |machine|
        params = {processor_size: machine["processor_size"].to_i,
                  processor_occupy_mode: machine["processor_occupy_mode"],
                  memory_size: machine["memory_size"].to_i}
        result = Business::ProduceOneContainer.new(@purpose, params).execute
        if result["result"] == false
          last_result = false
          message = "Can not provide #{params[:processor_size]} processors and #{params[:memory_size]}G memory for #{purpose}."
          produced_containers.try(:each) do |container_id|
            logger.info("Delete #{container_id} container for not satify all requires.}")
            Business::DeleteOneContainer.new({container_id: container_id}).execute
          end
          break
        end
        produced_containers.push(result["container_id"])
        update_db_status(result["container_id"])
        message.push({"id" => machine["id"], "ip" => result["ip"]})
      end
      {last_result: last_result, message: message}
    end

    def update_db_status(container_id)
      container = Container.where(container_id: container_id).first
      container.update_attributes(status: Container::STATUS_LIST['used']) if container
    end

    def logger_file_name
      @logger_file_name = "produce_containers/#{purpose}.log"
    end

  end
end
