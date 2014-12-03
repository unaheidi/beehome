class ProduceSpecialContainersWorker
  include Sidekiq::Worker

  def perform(demand,return_url)
    message = []
    last_result = true
    produced_containers = []
    demand = JSON.parse(demand)
    purpose = demand["purpose"]

    demand["machines"].each do |machine|
      params = {processor_size: machine["processor_size"],
                processor_occupy_mode: machine["processor_occupy_mode"],
                memory_size: machine["memory_size"]}
      result = Business::ProduceContainer.new(purpose, params).execute
      if result[0] == false
        last_result = false
        message = "No device can provide #{demand['processor_size']} processors and #{demand['memory_size']}G memory."
        produced_containers.try(:each) do |container_id|
          Business::DeleteContainer.new({container_id: container_id})
        end
        break
      end
      produced_containers.push(result[3])
      update_db_status(result[3])
      message.push(demand['id'] => result[2])
    end

    DeliverWorker.perform_async([last_result,message].to_json,return_url,[5, 10, 20 ,30])
  end

  def update_db_status(container_id)
    container = Container.where(container_id: container_id).first
    container.update_attributes(status: Container::STATUS_LIST['used']) if container
  end

end