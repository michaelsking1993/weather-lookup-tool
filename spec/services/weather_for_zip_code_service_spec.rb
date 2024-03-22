require 'rails_helper'
require 'webmock/rspec'

RSpec.describe WeatherForZipCodeService do
  describe '#call' do
    let!(:valid_zip_code) { build(:zip_code, zip_code: '19104') }
    
    context 'when the zip code is valid' do

      before do
        stub_request(:get, "https://api.weatherapi.com/v1/current.json?key=#{WeatherForZipCodeService::WEATHER_API_KEY}&q=#{valid_zip_code.zip_code}")
          .to_return(status: 200, body: successful_weather_response.to_json)
      end

      context "when the zip code's weather has not yet been cached" do
        it 'fetches new weather and returns success along with weather data' do
          expect_any_instance_of(described_class).to receive(:get_weather_for_zip).and_call_original # the weather SHOULD be fetched (no existing zip code)
          
          expect {
            expect(described_class.call(valid_zip_code)).to eq({ weather: successful_weather_response, pulled_from_cache: false })
          }.to change(ZipCode, :count).by(1) # it should persist a new zip code object into the database
        end
      end

      context 'when the weather is cached' do
        context 'when 30 minutes have not passed since the last request' do
          it 'returns cached weather along with time until refresh' do
            expect_any_instance_of(described_class).not_to receive(:get_weather_for_zip) # the weather should NOT be fetched again (time has not expired)
           
            valid_zip_code.update!(weather_forecast: successful_weather_response, weather_retrieved_at: 29.minutes.ago)
            
            expect {
              expect(described_class.call(valid_zip_code)).to eq({ weather: successful_weather_response, pulled_from_cache: true })
            }.not_to change(ZipCode, :count) # there should still be only one zip code in the database
          end
        end

        context 'when 30 minutes have already passed since the last request' do
          it 'fetches new weather and returns success along with the weather data' do
            expect_any_instance_of(described_class).to receive(:get_weather_for_zip).and_call_original # the weather SHOULD be fetched again (time has expired)
            
            valid_zip_code.update!(weather_forecast: successful_weather_response, weather_retrieved_at: 31.minutes.ago)
            
            expect {
              expect(described_class.call(valid_zip_code)).to eq({ weather: successful_weather_response, pulled_from_cache: false })
            }.not_to change(ZipCode, :count) # there should still be only one zip code in the database
          end
        end
      end
    end

    context 'when the zip code is invalid' do
      let(:invalid_zip_code) { build(:zip_code, zip_code: '7777777') }
      
      it 'returns an appropriate error message' do
        expect(described_class.call(invalid_zip_code)).to eq({ error: 'Zip code must be exactly 5 digits' })
      end
    end

    context 'when an error occurs while fetching weather' do
      let(:zip_code) { create(:zip_code, zip_code: '99999')}
      
      before do
        stub_request(:get, "https://api.weatherapi.com/v1/current.json?key=#{described_class::WEATHER_API_KEY}&q=99999")
          .to_return(status: 400, body: unsuccessful_weather_response.to_json)
      end
      
      it 'raises a WeatherServiceApiError and returns an error message' do
        expect(described_class.call(zip_code)).to eq({ error: 'No matching location found.' })
      end
    end
  end
end
