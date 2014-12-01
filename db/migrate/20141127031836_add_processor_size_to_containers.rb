class AddProcessorSizeToContainers < ActiveRecord::Migration
  def change
  	add_column :containers, :processor_size, :integer, after: :cpu_set
  end
end
