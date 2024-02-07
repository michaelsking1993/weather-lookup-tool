require 'uri'
require 'net/http'

class ZipCodeToWeatherService < ApplicationService

  class WeatherServiceApiError < StandardError; end

  WEATHER_API_BASE_URL = 'https://api.weatherapi.com/v1'
  # see .env.sample for the following API key.
  WEATHER_API_KEY = ENV['WEATHER_API_KEY']

  def initialize(zip_code)
    @zip_code = zip_code
  end

  def call
    zip_code = ZipCode.find_or_initialize_by(zip_code: @zip_code)
    if zip_code.valid?
      # if no weather is saved, or if the weather was saved more than 30 minutes ago, get the weather again.
      # Otherwise, return the cached weather along with the amount of time until refresh.
      if zip_code.weather_forecast.blank? || zip_code.weather_retrieved_at < 30.minutes.ago
        weather_forecast = get_weather_for_zip
        zip_code.update!(weather_retrieved_at: DateTime.current, weather_forecast: weather_forecast)
        # return new weather
        { success: true, weather: zip_code.weather_forecast, cached: false }
      else
        # return cached weather
        time_until_refresh = time_until_refresh(zip_code.weather_retrieved_at).round(2)
        { success: true, weather: zip_code.weather_forecast, cached: true, time_until_refresh: time_until_refresh }
      end
    else
      return { success: false, error: zip_code.errors.full_messages.join('; ') }
    end
  rescue WeatherServiceApiError => e
    return { success: false, error: e.message }
  end

  private

  def time_until_refresh(last_retrieved_at)
    ((last_retrieved_at + 30.minutes) - DateTime.current) / 1.minute
  end

  def get_weather_for_zip
    uri = URI("#{WEATHER_API_BASE_URL}/current.json?key=#{WEATHER_API_KEY}&q=#{@zip_code}")
    response = Net::HTTP.get_response(uri)
    parsed_body = JSON.parse(response.body)
    if response.is_a?(Net::HTTPSuccess)
      parsed_body
    else
      error_message = parsed_body&.[]('error')&.[]('message') || 'Unknown Error'
      raise WeatherServiceApiError.new(error_message)
    end
  end
end
