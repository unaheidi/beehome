class ProduceSpecialContainersWorker
  include Sidekiq::Worker
  include Sidekiq::Lock::Worker
  include Utils::Logger

  sidekiq_options lock: { timeout: 1000, name: 'lock-worker' }

  def perform(purpose,uid,machines,return_url)
    self.logger_file = logger_file_name
    if lock.acquire!
      begin
        try_to_produce_containers(purpose,uid,machines,return_url)
      ensure
        lock.release!
      end
    else
      ProduceSpecialContainersWorker.perform_async(purpose,uid,machines,return_url)
    end
  end

  def try_to_produce_containers(purpose,uid,machines,return_url)
    message = []
    last_result = true
    produced_containers = []
    purpose = purpose

    machines.each do |machine|
      params = {processor_size: machine["processor_size"].to_i,
                processor_occupy_mode: machine["processor_occupy_mode"],
                memory_size: machine["memory_size"].to_i}
      result = Business::ProduceContainer.new(purpose, params).execute
      if result["result"] == false
        last_result = false
        message = "Can not provide #{params[:processor_size]} processors and #{params[:memory_size]}G memory for #{purpose}."
        produced_containers.try(:each) do |container_id|
          logger.info("Delete #{container_id} container for not satify all requires.}")
          Business::DeleteContainer.new({container_id: container_id}).execute
        end
        break
      end
      produced_containers.push(result["container_id"])
      update_db_status(result["container_id"])
      message.push({"id" => machine["id"], "ip" => result["ip"]})
    end

    DeliverWorker.perform_async({"uid"=> uid,"result" => last_result,"message" => message},return_url,[5, 10, 20 ,30]) if return_url
  end

  def update_db_status(container_id)
    container = Container.where(container_id: container_id).first
    container.update_attributes(status: Container::STATUS_LIST['used']) if container
  end

  def logger_file_name
    @logger_file_name = "workers/produce_special_containers/delete_container.log"
  end

end