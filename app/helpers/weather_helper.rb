module WeatherHelper
  
  # input: a zip code object
  # output: how many minutes ago, in words, the weather forecast was retrieved at. Note, this will include seconds when the value is less than 1 minute 29 seconds.
  def retrieved_at_minutes_ago(zip_code)
    time_ago_in_words(zip_code.weather_retrieved_at, include_seconds: true)
  end

  # input: a zip code object
  # output: how many minutes, in words, until the weather forecast gets refreshed. Note, this will include seconds when the value is less than 1 minute 29 seconds.
  def will_refresh_at_in_minutes(zip_code)
    distance_of_time_in_words(DateTime.current, zip_code.weather_retrieved_at + 30.minutes, include_seconds: true)
  end
end
