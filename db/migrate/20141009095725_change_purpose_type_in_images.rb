class ChangePurposeTypeInImages < ActiveRecord::Migration
  def up
    change_column :images, :purpose, :string
  end

  def down
    change_column :images, :purpose, :integer
  end
end
