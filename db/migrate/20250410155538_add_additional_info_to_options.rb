class AddAdditionalInfoToOptions < ActiveRecord::Migration[8.0]
  def change
    add_column :options, :additional_info, :text
  end
end
