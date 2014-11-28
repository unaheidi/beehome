class AddProcessorOccupyModeToContainers < ActiveRecord::Migration
  def change
  	add_column :containers, :processor_occupy_mode, :string, after: :processor_size
  end
end
