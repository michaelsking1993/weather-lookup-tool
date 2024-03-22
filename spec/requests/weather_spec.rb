require 'rails_helper'

RSpec.describe 'Weather API', type: :request do
  describe 'GET /weather_for_zip' do
    context 'when the zip code is valid' do
      before do
        stub_request(:get, "https://api.weatherapi.com/v1/current.json?key=#{WeatherForZipCodeService::WEATHER_API_KEY}&q=12345")
          .to_return(status: 200, body: successful_weather_response.to_json)
      end
      
      context 'when the zip code does not yet exist' do
        it 'persists the zip code' do
          expect {
            get '/weather_for_zip', params: { zip_code: '12345' }
          }.to change(ZipCode, :count).by(1)
          
          expect(response.body).to include('This is the most up-to-date weather forecast!')
        end
      end
      
      context 'when the zip code already exists' do
        before do
          # cached 10 minutes ago. So the body should say so.
          create(:zip_code, zip_code: '12345', weather_retrieved_at: 10.minutes.ago, weather_forecast: successful_weather_response)
        end
        
        it 'does not create another one' do
          expect {
            get '/weather_for_zip', params: { zip_code: '12345' }
          }.not_to change(ZipCode, :count)
          
          expect(response.body).to include('The following weather was retrieved <strong>10 minutes ago.</strong>')
          expect(response.body).to include('It will refresh in <strong>20 minutes.</strong>')
        end
      end
    end
    
    context 'when the zip code is NOT valid' do
      it 'does not persist the zip code' do
        expect {
          get '/weather_for_zip', params: { zip_code: '1234567890' }
        }.not_to change(ZipCode, :count)
        
        expect(response.body).to include('Zip code must be exactly 5 digits')
      end
    end
  end
end
