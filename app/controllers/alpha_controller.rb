class AlphaController < ApplicationController
  before_filter {self.nav = 'alpha'}
  before_filter :authorize_user

  def index
    @containers = Container.
      order('updated_at desc').
      includes(:ip_address, :image).
      where(image_id: [1,2,3], status: [0,1]).
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
end
