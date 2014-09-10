class AddGatewayToDevice < ActiveRecord::Migration
  def change
  	add_column :devices, :gateway, :string, after: :ip
  end
end
