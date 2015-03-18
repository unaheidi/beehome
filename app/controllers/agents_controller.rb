class AgentsController < ApplicationController
  before_filter {self.nav = 'agent'}
  def index
    @containers = Container.
      includes(:ip_address, :image).
      where(image_id: [4,6], status: [0,1]).
      order(created_at: :desc).
      page(params[:page])
  end

  def remove_ips
    delete_container_worker = DeleteContainersWorker.new
    delete_container_worker.perform_web(params[:ips],"jagent")
    head :ok
  end
end
