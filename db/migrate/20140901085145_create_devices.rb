class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :ip
      t.string :os
      t.string :docker_remote_api
      t.integer :status

      t.timestamps
    end
  end
end
