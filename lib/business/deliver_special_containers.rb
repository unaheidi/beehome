module Business
  class DeliverSpecialContainers
    include SidekiqStatus::Worker

    class << self
      def info_proposer(produce_jid,return_url,intervals)
        begin
          sidekiq_container = SidekiqStatus::Container.load(produce_jid)
          raise "The task to rebuild the container hasn't finished." if sidekiq_container.status.to_s !~ /complete|failed/
          #result = Service::Gitpub::Connection.new(gitpub_url: return_url[0..return_url.index('/')]).get(return_url[return_url.index('/')..-1], {ip: ip_address})
          #puts "http result:" + result.to_s
          puts sidekiq_container.payload
        rescue
          if intervals.blank?
            puts "Deliver special containers with failed."
          else
            puts "Deliver special containers again."
            Business::DeliverSpecialContainers.delay_for(intervals.shift.seconds, :retry => false).info_proposer(produce_jid,return_url,intervals || [])
          end
        end
      end
    end
  end
end