class AddCpuSetToContainers < ActiveRecord::Migration
  def change
  	add_column :containers, :cpu_set, :string, after: :ip_address_id
  end
end
