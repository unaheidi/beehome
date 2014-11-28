class AddPurposeToDevices < ActiveRecord::Migration
  def change
  	add_column :devices, :purpose, :string, after: :status
  end
end
