class DeleteContainersWorker
  include Sidekiq::Worker

  def perform(uid,machines,purpose,return_url)
    self.logger_file = logger_file_name
    last_result = true
    message = []

    machines.each do |machine|
      ip_address = IpAddress.where(address: machine['ip']).first
      to_be_deleted_container = Container.purpose(purpose).where(ip_address_id: ip_address.id).
                                  where(status: Container::STATUS_LIST['used']).first
      if to_be_deleted_container.nil?
        logger.error("The to be deleted container with machine['ip'] doesn't exist.}")
        message.push({"id" => machine['id'], "state" => false})
        next
      else
        result = Business::DeleteContainer.new(container_id: to_be_deleted_container.container_id).execute
        last_result = false if result["result"] == false
        message.push({"id" => machine['id'], "state" => result["result"]})
      end
    end
    Rails.logger.info("callback :result: #{last_result} uid:#{uid} message: #{message}")
    DeliverWorker.perform_async({"result" => last_result, "uid" => uid, "message" => message},return_url,[5, 10, 20 ,30]) if return_url
  end

  def logger_file_name
    @logger_file_name = "workers/delete_containers/delete_container.log"
  end
end