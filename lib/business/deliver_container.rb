module Business
  class DeliverContainer
    include SidekiqStatus::Worker

    class << self
      def info_proposer(rebuild_jid,ip_address,return_url,intervals)
        begin
          sidekiq_container = SidekiqStatus::Container.load(rebuild_jid)
          raise "The task to rebuild the container hasn't finished." if sidekiq_container.status.to_s != "complete"
          result = Service::Gitpub::Connection.new(gitpub_url: return_url[0..return_url.index('/')]).get(return_url[return_url.index('/')..-1], {ip: ip_address})
          puts "http result:" + result.to_s
        rescue
          if intervals.blank?
            puts "Deliver container with #{ip_address} failed."
          else
            puts "Deliver container again."
            Business::DeliverContainer.delay_for(intervals.shift.seconds, :retry => false).info_proposer(rebuild_jid,ip_address,return_url,intervals || [])
          end
        end
      end
    end
  end
end