class AddResourceReferenceIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :resource_reference_id, :integer
  end
end
