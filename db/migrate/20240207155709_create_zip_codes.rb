class CreateZipCodes < ActiveRecord::Migration[7.1]
  def change
    create_table :zip_codes do |t|
      t.string :zip_code
      t.jsonb :weather_forecast

      t.datetime :weather_retrieved_at
      t.timestamps
    end
  end
end
