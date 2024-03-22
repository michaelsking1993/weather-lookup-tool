# frozen_string_literal: true

module JsonResponseHelper

  # taken from the API response for a valid zip code.
  def successful_weather_response
    JSON.parse(File.read('./spec/fixtures/successful_weather_response.json'))
  end

  # taken from the API response for an invalid zip code.
  def unsuccessful_weather_response
    JSON.parse(File.read('./spec/fixtures/unsuccessful_weather_response.json'))
  end
end