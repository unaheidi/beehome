class AddMemorySizeToDevices < ActiveRecord::Migration
  def change
  	add_column :devices, :memory_size, :integer, after: :processor_size
  end
end
