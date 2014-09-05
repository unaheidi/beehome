class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :repository
      t.string :tag
      t.string :image_id
      t.string :dockerfile_url
      t.integer :purpose
      t.integer :status

      t.timestamps
    end
  end
end
