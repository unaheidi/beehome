# encoding: utf-8
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

  def new_ip
    ip = params[:ip]

    response = Business::ProduceContainer.new('alpha',{}, ip).execute

    if response.present? && response['result'] == true
      flash[:success] = '创建alpha 虚机成功'
      head :ok
    else
      flash[:danger] = "创建alpha 虚机失败 ERROR:#{response['message']}"
      head :bad_request
    end

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
