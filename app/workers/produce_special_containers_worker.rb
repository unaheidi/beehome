class ProduceSpecialContainersWorker
  include Sidekiq::Worker

  def perform(purpose,machines,return_url)
    message = []
    last_result = true
    produced_containers = []
    purpose = purpose

    machines.each do |machine|
      params = {processor_size: machine["processor_size"].to_i,
                processor_occupy_mode: machine["processor_occupy_mode"],
                memory_size: machine["memory_size"].to_i}
      result = Business::ProduceContainer.new(purpose, params).execute
      if result[0] == false
        last_result = false
        message = "No device can provide #{params[:processor_size]} processors and #{params[:memory_size]}G memory."
        produced_containers.try(:each) do |container_id|
          Business::DeleteContainer.new({container_id: container_id})
        end
        break
      end
      produced_containers.push(result[3])
      update_db_status(result[3])
      message.push(machine['id'] => result[2])
    end

    DeliverWorker.perform_async([last_result,message].to_json,return_url,[5, 10, 20 ,30])
  end

  def update_db_status(container_id)
    container = Container.where(container_id: container_id).first
    container.update_attributes(status: Container::STATUS_LIST['used']) if container
  end

end