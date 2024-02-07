require 'rails_helper'
require 'webmock/rspec'

RSpec.describe "ZipCodeToWeatherService" do
  describe '#call' do
    let(:zip_code) { '19104' }
    let(:service) { ZipCodeToWeatherService.new(zip_code) }

    context 'when the zip code is valid' do
      let(:weather_forecast) { { 'current' => { 'location' => { 'name' => 'Philadelphia', 'region' => 'Pennsylvania' },
                                                'condition' => { 'text' => 'Partly cloudy'}}, 'description' => 'Sunny' } }

      before do
        stub_request(:get, "https://api.weatherapi.com/v1/current.json?key=#{ZipCodeToWeatherService::WEATHER_API_KEY}&q=19104")
          .to_return(status: 200, body: weather_forecast.to_json)
      end

      context "when the zip code's weather has not yet been cached" do
        it 'fetches new weather and returns success along with weather data' do
          expect(ZipCode.count).to eq(0)
          expect_any_instance_of(ZipCodeToWeatherService).to receive(:get_weather_for_zip).and_call_original # the weather should be fetched
          expect(service.call).to eq({ success: true, weather: weather_forecast, cached: false })
          expect(ZipCode.count).to eq(1) # it should persist a new zip code object into the database
        end
      end

      context 'when the weather is cached' do
        context 'when 30 minutes have not passed since the last request' do

          before do
            create(:zip_code, zip_code: '19104', weather_forecast: weather_forecast, weather_retrieved_at: 29.minutes.ago)
          end

          it 'returns cached weather along with time until refresh' do
            expect_any_instance_of(ZipCodeToWeatherService).not_to receive(:get_weather_for_zip) # the weather should NOT be fetched
            expect(ZipCode.count).to eq(1)
            expect(service.call).to eq({ success: true, weather: weather_forecast, cached: true, time_until_refresh: 1 })
            expect(ZipCode.count).to eq(1) # there should still be only one zip code in the database
          end
        end

        context 'when 30 minutes have already passed since the last request' do

          before do
            create(:zip_code, zip_code: '19104', weather_forecast: weather_forecast, weather_retrieved_at: 31.minutes.ago)
          end

          it 'fetches new weather and returns success along with the weather data' do
            expect_any_instance_of(ZipCodeToWeatherService).to receive(:get_weather_for_zip).and_call_original # the weather should NOT be fetched
            expect(ZipCode.count).to eq(1)
            expect(service.call).to eq({ success: true, weather: weather_forecast, cached: false })
            expect(ZipCode.count).to eq(1) # there should still be only one zip code in the database
          end
        end
      end
    end

    context 'when the zip code is invalid' do
      it 'returns an appropriate error message' do
        expect(ZipCodeToWeatherService.call('111111')).to eq({ success: false, error: 'Zip code must be exactly 5 digits' })
      end
    end

    context 'when an error occurs while fetching weather' do
      it 'raises a WeatherServiceApiError and returns an error message' do
        allow_any_instance_of(ZipCodeToWeatherService).to receive(:get_weather_for_zip).and_raise(ZipCodeToWeatherService::WeatherServiceApiError, 'Weather service error')
        expect(ZipCodeToWeatherService.call('11111')).to eq({ success: false, error: 'Weather service error' })
      end
    end
  end
end