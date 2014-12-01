class ProduceSpecialContainersWorker
  include SidekiqStatus::Worker
  sidekiq_options queue: :default, retry: false

  def perform(demands)
    message = []
    last_result = true
    produced_containers = []
    demands = JSON.parse(demands)
    purpose = demands.first

    demands[1..demands.size].each do |demand|
      params = {processor_size: demand['processor_size'],
                processor_occupy_mode: demand['processor_occupy_mode'],
                memory_size: demand['memory_size']}
      result = Business::ProduceContainer.new(purpose, params).execute
      if result[0] == false
        last_result = false
        message = "No device can provide #{demand['processor_size']} processors and #{demand['memory_size']}G memory."
        self.payload = {result: last_result, message: message}
        produced_containers.try(:each) do |container_id|
          Business::DeleteContainer.new({container_id: container_id})
        end
        break
      end
      produced_containers.push(result[3])
      message.push(demand['id'] => result[2])
    end

    self.payload = {result: last_result, message: message}
  end

end