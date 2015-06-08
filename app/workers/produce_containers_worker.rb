class ProduceContainersWorker
  include Sidekiq::Worker
  include Sidekiq::Lock::Worker
  include Utils::Logger

  sidekiq_options lock: { timeout: 3000, name: 'lock-worker' }

  def perform(purpose,uid,machines,return_url)
    self.logger_file = logger_file_name
    if lock.acquire!
      begin
        produce_containers_and_callback(purpose,uid,machines,return_url)
      ensure
        lock.release!
      end
    else
      ProduceContainersWorker.perform_async(purpose,uid,machines,return_url)
    end
  end

  def produce_containers_and_callback(purpose,uid,machines,return_url)
    result = Business::ProduceContainers.new(purpose,machines).execute
    last_result = result[:last_result]
    message = result[:message]

    sleep(5)
    DeliverWorker.perform_async({"uid"=> uid,"result" => last_result,"message" => message},return_url,[5, 10, 20 ,30]) if return_url
  end

  def logger_file_name
    @logger_file_name = "workers/produce_special_containers/delete_container.log"
  end

end