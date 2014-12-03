class DeleteContainersWorker
  include SidekiqStatus::Worker

  def perform(container_ips,purpose,return_url)
  	last_result = true
    message = []
  	container_ips.each do |container_ip|
  		ip_address = IpAddress.where(address: container_ip).first
  		to_be_deleted_container = Container.purpose(purpose).where(ip_address_id: ip_address.id).
  		                            where(status: Container::STATUS_LIST['used']).first
  		result = Business::DeleteContainer.new(container_id: to_be_deleted_container.container_id).execute # container_id: ce1cbfbefe45
  	  last_result = false if result["result"] == false
      message.push(result)
  	end
    DeliverWorker.perform_async({"result" => last_result, "message" => message},return_url,[5, 10, 20 ,30]) if return_url
  end
end