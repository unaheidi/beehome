module API

  class Containers < Grape::API

    namespace 'containers' do
      get "/" do
        { containers: 1 }
      end

      get "apply_random_containers" do
      	containers_number = params["number"].to_i
      	purpose = params["purpose"]
      	image_ids = Image.where(purpose: purpose, status: Image::STATUS_LIST['recommended']).pluck(:id)
      	containers = Container.where(status: Container::STATUS_LIST['available']).where(image_id: image_ids).limit(containers_number)
        return {result: 0, message: "Failed.No free container with recommended image."} if containers.blank?
        ip_addresses = []
        containers.each do |container|
        	container.update_attributes(status: Container::STATUS_LIST['used'])
        	ip_addresses.push(container.ip_address.address)
        end
        if containers.size < containers_number
        	return {result: 1, message: "Less than the request numer.", purpose: purpose, ip_addresses: ip_addresses}
        else
        	return {result: 2, message: "Successfully.", purpose: purpose, ip_addresses: ip_addresses}
        end
      end

      post "rebuild_a_container" do
        container_ip = params["ip"]
        return_url = params["return_url"]
        ip_address = IpAddress.where(address: container_ip).first
        return {result: 0, message: "Failed.No such ip record in ip_addresses table."} if ip_address.blank?
        to_be_deleted_container = Container.where(ip_address_id: ip_address.id).where(status: Container::STATUS_LIST['used']).first
        return {result: 0, message: "Failed.No container with the specified ip in containers table."} if to_be_deleted_container.blank?
        rebuild_jid = RebuildContainerWorker.perform_async(to_be_deleted_container.container_id)
        Business::DeliverRebuildContainer.delay_for(3.seconds, :retry => false).info_proposer(rebuild_jid,ip_address.address,return_url,[15,30,30])
        return {result: 1, message: "Beehome is going to rebuild the container with ip #{container_ip} !"}
      end

      post "apply_special_containers" do
        return_url = "http://baidu.com"
        demands = [
          "performance_test",
          {
            "id" => '001',
            "processor_size" => 2,
            "processor_occupy_mode" => "private",
            "memory_size" => 4,
          },
          {
            "id" => '002',
            "processor_size" => 4,
            "processor_occupy_mode" => "share",
            "memory_size" => 4,
          },
        ]
        produce_jid = ProduceSpecialContainersWorker.perform_async(demands)
        Business::DeliverSpecialContainers.delay_for(3.seconds, :retry => false).info_proposer(produce_jid,demands,return_url,[15,30,30])
        return {result: 1, message: "Beehome is going to provide the containers !"}
      end

    end
  end
end

