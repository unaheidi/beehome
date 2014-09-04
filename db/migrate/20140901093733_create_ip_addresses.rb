class CreateIpAddresses < ActiveRecord::Migration
  def change
    create_table :ip_addresses do |t|
      t.string :address
      t.string :netmask
      t.integer :device_id
      t.integer :status

      t.timestamps
    end
  end
end
