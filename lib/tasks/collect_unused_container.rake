desc "Collect unused container"

task collect_unused_performance_container: :environment do
  Container.where(status: [0,1]).where(Time.now - updated_at >= 5.minutes).each do |container|

    if container.ip_address_id
      ip_addr = IpAddress.find_by_id(container.ip_address_id)
    end

    if container.purpose == 'performance_test' && ip_addr

      conn = Service::Gitpub::Connection 

      gitlab_url = Settings.gitlab.destroy_machine
      post_url = Settings.gitlab.post_url

      resp = conn.new({gitpub_url:gitlab_url}).post(post_url,
                                                     {ip: ip_addr.address},
                                                     "query")
      begin
        result = JSON.parse(resp.body)
      rescue => error
        Rails.logger.info("parse json error")
      end
      is_destory = result["result"]

      if is_destory == "true"
        # call Delete Contailner

        Rail.logger.info("Start destroy machine [#{ip_addr.address}]")

        DeleteContainersWorker.perform_async(ip_addr.address,
                                             container.purpose,
                                             nil)
      end

    end

  end


end
