class AddMemorySizeToContainers < ActiveRecord::Migration
  def change
  	add_column :containers, :memory_size, :integer, after: :processor_occupy_mode
  end
end
