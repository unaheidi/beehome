class ContainersController < ApplicationController
  before_filter {self.nav = 'container'}
  def index
    @containers = Container.
      includes(:ip_address, :image).
      where(image_id: [4,5,6], status: [0,1]).
      order(created_at: :desc).
      page(params[:page])
  end

  def remove_ips
    delete_container_worker = DeleteContainersWorker.new
    delete_container_worker.perform_web(params[:ips],"performance_test")
    head :ok
  end
end
