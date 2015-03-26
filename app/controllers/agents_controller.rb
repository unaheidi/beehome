class AgentsController < ApplicationController
  before_filter {self.nav = 'agent'}
  before_filter :authorize_user
  def index
    @containers = Container.
      includes(:ip_address, :image).
      where(image_id: [4,6], status: [0,1]).
      order(created_at: :desc).
      page(params[:page])
  end

  def rebuild
    params[:ips].each do |ip|
      ip_address = IpAddress.where(address: ip).first
      to_be_deleted_container = Container.where(ip_address_id: ip_address.id).where(status: [0,1]).first

      Business::RebuildContainer.new({container_id: to_be_deleted_container.container_id}).execute
    end
    head :ok
  end

  def remove_ips
    delete_container_worker = DeleteContainersWorker.new
    delete_container_worker.perform_web(params[:ips],"jagent")
    head :ok
  end
end
