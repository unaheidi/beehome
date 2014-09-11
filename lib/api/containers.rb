module API

  class Containers < Grape::API

    namespace 'containers' do
      get "/" do
        { containers: 1 }
      end

      get "apply" do
      	debugger
      	containers_number = params["number"].to_i
      	purpose = params["purpose"]
      	image_ids = Image.where(purpose: purpose, status: Image::STATUS_LIST['recommended']).pluck(:id)
      	containers = Container.where(status: Container::STATUS_LIST['available']).where(image_id: image_ids).limit(containers_number)
        return {result: "Failed.No free container or no image for the purpose."} if containers.blank?
        ip_addresses = []
        containers.each do |container|
        	container.update_attributes(status: Container::STATUS_LIST['used'])
        	ip_addresses.push(container.ip_address.address)
        end
        if containers.size < containers_number
        	return {result: "Less than the request numer.", ip_addresses: ip_addresses}
        else
        	return {result: "Successfully.", ip_addresses: ip_addresses}
        end
      end

    end
  end
end

