class RebuildContainerWorker
  include SidekiqStatus::Worker

  def perform(container_id,return_url)
    result = Business::RebuildContainer.new(container_id: container_id).execute # container_id: ce1cbfbefe45
    DeliverWorker.perform_async(result.to_json,return_url,[5, 10, 20 ,30])
  end
end