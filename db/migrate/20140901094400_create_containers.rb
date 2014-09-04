class CreateContainers < ActiveRecord::Migration
  def change
    create_table :containers do |t|
      t.string :container_id
      t.integer :image_id
      t.integer :ip_address_id
      t.integer :status

      t.timestamps
    end
  end
end
