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
        return {result: 0, message: "Less than the request numer."} if containers.size < containers_number
        ip_addresses = []
        containers.each do |container|
        	container.update_attributes(status: Container::STATUS_LIST['used'])
        	ip_addresses.push(container.ip_address.address)
        end
        return {result: 1, message: "Successfully.", purpose: purpose, ip_addresses: ip_addresses}
      end

      post "rebuild_a_container" do
        container_ip = params["ip"]
        return_url = params["return_url"]
        ip_address = IpAddress.where(address: container_ip).first
        return {result: 0, message: "Failed.No such ip record in ip_addresses table."} if ip_address.blank?
        to_be_deleted_container = Container.where(ip_address_id: ip_address.id).where(status: Container::STATUS_LIST['used']).first
        return {result: 0, message: "Failed.No container with the specified ip in containers table."} if to_be_deleted_container.blank?
        RebuildOneContainerWorker.perform_async(to_be_deleted_container.container_id,return_url)
        return {result: 1, message: "Beehome is going to rebuild the container with ip #{container_ip} !"}
      end

      post "apply_special_containers" do
        return {result: 0, message: "No params error!"} if params.nil?
        return_url = params["return_url"]
        uid = params["uid"]
        purpose = params["purpose"]
        machines = params["machines"]
        return {result: 0, message: "No return_url error!"} if return_url.nil?
        return {result: 0, message: "No purpose error!"} if purpose.nil?
        return {result: 0, message: "No machiens error!"} if machines.nil?
        return {result: 0, message: "No uid error!"} if uid.nil?

        ProduceContainersWorker.perform_async(purpose,uid,machines,return_url)
        return {result: 1, message: "Beehome is going to provide the containers !"}
      end

      post "delete_containers" do

        uid = params['uid']
        purpose = params['purpose']
        return_url = params['return_url']
        machines = params['machines']

        machines.each do |machine|
          ip = machine["ip"]
          ip_address = IpAddress.where(address: ip).first
          return {result: 0, message: "Failed.No such ip #{ip} record in ip_addresses table."} if ip_address.blank?
          to_be_deleted_container = Container.where(ip_address_id: ip_address.id).
                                      where(status: Container::STATUS_LIST['used']).purpose(purpose).first
          return {result: 1, message: "Failed.No #{purpose} container with the specified ip #{ip} in containers table."} if to_be_deleted_container.blank?

        end
        DeleteContainersWorker.perform_async(uid, machines, purpose, return_url)
        return {result: 2, message: "Beehome is going to delete the containers !"}
      end

    get "docker_info" do
      ip = params['ip']
      ip_address = IpAddress.find_by_address(ip)

      docker = Container.where(ip_address_id: ip_address.id, status: [0, 1])

      device = Device.find(ip_address.device_id)
      if device && device.ip
        device_ip = device.ip
      else
        device_ip =nil
      end

      if docker && docker.first
        instance_id = docker.first.container_id
      else
        instance_id = nil
      end
      return { ip: ip, device_ip: device_ip, instance_id: instance_id}
    end

    end

  end
end

