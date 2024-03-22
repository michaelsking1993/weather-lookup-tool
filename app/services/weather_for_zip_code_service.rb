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
  #           { error: string[if applicable], pulled_from_cache: true/false[if applicable], weather: hash[if applicable] }
  def call
    current_time = DateTime.current
    if zip_code.valid? && needs_updated_weather?
      zip_code.update!(weather_retrieved_at: current_time, weather_forecast: get_weather_for_zip)
    end
    
    { 
      weather: zip_code.weather_forecast.presence, 
      pulled_from_cache: zip_code.id && zip_code.weather_retrieved_at != current_time, # `zip_code.id &&` allows us to remove this field (through .compact) if zip_code was invalid.
      error: zip_code.errors.full_messages.join('; ').presence 
    }.compact
  rescue WeatherServiceApiError => e 
    { error: e.message }
  end

  private
  
  def needs_updated_weather?
    # we need to fetch updated weather if a) there is no weather for this zip_code object (i.e. if it's new), or b) the weather was retrieved more than 30 minutes ago.
    zip_code.weather_forecast.blank? || zip_code.weather_retrieved_at < 30.minutes.ago
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
