class AddIndexToZipCodeOnZipCodes < ActiveRecord::Migration[7.1]
  def change
    add_index :zip_codes, :zip_code, unique: true
  end
end
