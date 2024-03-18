require 'uri'
require 'net/http'

class WeatherForZipCodeService < ApplicationService
  attr_reader :zip_code
  
  WEATHER_API_BASE_URL = 'https://api.weatherapi.com/v1'
  # see .env.sample for the following API key.
  WEATHER_API_KEY = ENV['WEATHER_API_KEY']

  class WeatherServiceApiError < StandardError; end
  
  def initialize(zip_code)
    @zip_code = zip_code
  end

  # input: an ActiveRecord zip-code object
  # output: a hash object in the following format, used by the view to render appropriate information for the person viewing the weather:
  #           { success: true/false, error: string[if applicable], pulled_from_cache: true/false }
  def call
    if zip_code.valid?
      # if no weather is saved, or if the weather was saved more than 30 minutes ago, get the weather again.
      # Otherwise, return the cached weather along with the amount of time until refresh.
      if zip_code.weather_forecast.blank? || zip_code.weather_retrieved_at < 30.minutes.ago
        # fetch new weather. update! will persist the newly initialized zip code object if it does not already exist.
        zip_code.update!(weather_retrieved_at: DateTime.current, weather_forecast: get_weather_for_zip)
        
        { success: true, weather: zip_code.weather_forecast, pulled_from_cache: false }
      else
        # fetch cached weather
        time_until_refresh = time_until_refresh(zip_code.weather_retrieved_at).round(2)
        
        { success: true, weather: zip_code.weather_forecast, pulled_from_cache: true }
      end
    else
      { success: false, error: zip_code.errors.full_messages.join('; ') }
    end
  rescue WeatherServiceApiError => e 
    { success: false, error: e.message }
  end

  private

  # input: datetime of the last time the weather was retrieved
  # output: how long (in minutes) until the next refresh, where each refresh happens at 30 minute intervals.
  def time_until_refresh(last_retrieved_at)
    next_refresh_at = last_retrieved_at + 30.minutes # the next refresh happens 30 minutes after the last retrieval
    time_until_next_refresh = next_refresh_at - DateTime.current # the difference (in seconds) between the next refresh time, and the current time
    
    time_until_next_refresh / 1.minute # converts that difference into minutes
  end
  
  
  # Fetches weather forecast from our selected weather API. Returns the parsed body of the weather API's response.
  def get_weather_for_zip
    uri = URI(generate_weather_url)
    response = Net::HTTP.get_response(uri)
    parsed_body = JSON.parse(response.body)
    
    if response.is_a?(Net::HTTPSuccess)
      parsed_body
    else
      error_message = parsed_body.dig('error', 'message') || 'Unknown Error'
      
      raise WeatherServiceApiError, error_message
    end
  end
  
  def generate_weather_url
    "#{WEATHER_API_BASE_URL}/current.json?key=#{WEATHER_API_KEY}&q=#{@zip_code.zip_code}"
  end
end
