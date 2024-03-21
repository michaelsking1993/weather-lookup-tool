class CreateZipCodes < ActiveRecord::Migration[7.1]
  def change
    create_table :zip_codes do |t|
      t.string :zip_code
      
      # jsonb is stored in a decomposed binary format that makes it slower to input than json due to conversion overhead,
      # but significantly faster to read than json since no re-parsing is needed.
      t.jsonb :weather_forecast

      t.datetime :weather_retrieved_at
      t.timestamps
    end
  end
end
