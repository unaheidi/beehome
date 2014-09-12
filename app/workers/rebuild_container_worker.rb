class RebuildContainerWorker
  include Sidekiq::Worker

  def perform(container_id)
    Business::RebuildContainer.new(container_id: container_id).execute # container_id: ce1cbfbefe45
  end
end