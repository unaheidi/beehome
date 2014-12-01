class DeliverWorker
  include Sidekiq::Worker

  def perform(information,return_url,intervals)
    begin
      puts information
      result = Service::Gitpub::Connection.new(gitpub_url: return_url[0..return_url.index('/')])
                  .get(return_url[return_url.index('/')..-1], information)
    rescue => e
      if intervals.blank?
        puts "[Callback failed] *** #{return_url}......#{information} ***"
      else
        DeliverWorker.delay_for(intervals.shift.seconds, :retry => false).perform_async(information,return_url,intervals[1..-1] || [])
      end
    end

  end

end