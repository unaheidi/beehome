class AddProcessorSizeToDevices < ActiveRecord::Migration
  def change
  	add_column :devices, :processor_size, :integer, after: :os
  end
end
