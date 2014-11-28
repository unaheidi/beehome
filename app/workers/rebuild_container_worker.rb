class RebuildContainerWorker
  include SidekiqStatus::Worker

  def perform(container_id)
    ip_address = Business::RebuildContainer.new(container_id: container_id).execute # container_id: ce1cbfbefe45
    puts ip_address
    self.payload = {ip_address: ip_address}
  end
end