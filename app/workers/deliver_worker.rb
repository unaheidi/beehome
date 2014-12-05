class DeliverWorker
  include Sidekiq::Worker
  include Utils::Logger
  include Utils::Time

  def perform(information,return_url,intervals)
    self.logger_file = logger_file_name
    begin
      return_url.gsub!(/http:\/\//,'')
      result = Service::Gitpub::Connection.new(gitpub_url: return_url[0..return_url.index('/')]).post(return_url[return_url.index('/')..-1], information, "query")
    rescue => e
      if intervals.blank?
        message =  "[Callback failed] *** #{return_url}......#{information} ***"
        logger.error("DeliverWorker failed, error message: #{e}.#{message}")

      else
        DeliverWorker.delay_for(intervals.shift.seconds, :retry => false).perform_async(information,return_url,intervals[1..-1] || [])
      end
    end

  end

  def logger_file_name
    @logger_file_name = "deliver_container/all.log"
  end

end