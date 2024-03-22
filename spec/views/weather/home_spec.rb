require 'rails_helper'

RSpec.describe 'weather/home', type: :view do
  
  context 'when page just loaded (i.e. no weather object)' do
    it 'does not show any weather data, gives instructions on how to get started' do
      render
      
      assert_select '#get-started-instructions', text: 'Please input a zip code to get started!', count: 1
      assert_select '#weather-information', count: 0
      assert_select '#error-text', count: 0
    end
  end
  
  context 'when zip code is entered' do
    context 'when the zip code has an error with it' do
      it 'shows that error' do
        @weather_object = {
          error: 'No matching location found.'
        }
        
        render
        
        # should render the error text
        assert_select '#error-text', text: @weather_object[:error], count: 1
        
        # should not render any weather information
        assert_select '#weather-information', count: 0
      end
    end
    
    context 'when the zip code is valid' do
      context 'when the weather has just been fetched with this request' do
        it 'shows that it was just fetched' do
          @zip_code = create(:zip_code, zip_code: '19104')
          @weather_object = {
            weather: successful_weather_response,
            pulled_from_cache: false
          }
          
          render
          
          assert_select '#up-to-date-weather-info', text: 'This is the most up-to-date weather forecast!', count: 1
          
          # should not render anything related to refresh time, nor errors.
          assert_select '#weather-pulled-from-cache-info', count: 0
          assert_select '#error-text', count: 0
          
          normal_weather_expectations
        end
      end

      context 'when the weather was pulled from the cache' do
        it 'tells how long until the next time the weather will be refreshed' do
          @zip_code = create(:zip_code, zip_code: '19104', weather_retrieved_at: 7.minutes.ago)
          @weather_object = {
            weather: successful_weather_response,
            pulled_from_cache: true
          }
          
          render
          
          # should render info about how old this weather is, and when it will refresh again.
          minutes_ago_text = 'The following weather was retrieved 7 minutes ago.'
          will_refresh_in_text = 'It will refresh in 23 minutes.'
          assert_select '#weather-pulled-from-cache-info', text: /#{minutes_ago_text}\s+#{will_refresh_in_text}/, count: 1

          # should not render anything related to errors, nor about this weather being up-to-date (since it isn't)
          assert_select '#up-to-date-weather-info', count: 0
          assert_select '#error-text', count: 0

          normal_weather_expectations
        end
      end
    end
  end
  
  def normal_weather_expectations
    # NOTE: to corroborate these texts, see successful_weather_response.json
    assert_select '#location', text: 'Location: Philadelphia, Pennsylvania (19104)'
    assert_select '#current-weather', text: 'Current Weather: Clear'
    assert_select '#current-temperature', text: 'Temperature: 41.0 ℉ (5.0 ℃)'
    assert_select '#feels-like-temperature', text: 'Feels like: 35.4 ℉ (1.9 ℃)'
    assert_select '#wind-gusts', text: 'Wind Gusts: 17.0 mph (27.4 kph)'
  end
end