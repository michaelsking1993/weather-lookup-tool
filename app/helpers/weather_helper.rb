module WeatherHelper
  
  # input: a zip code object
  # output: how many minutes ago, in words, the weather forecast was retrieved at.
  def retrieved_at_minutes_ago(retrieved_at)
    time_ago_in_words(retrieved_at, include_seconds: true)
  end

  # input: a zip code object
  # output: how many minutes, in words, until the weather forecast gets refreshed.
  def will_refresh_at_in_minutes(retrieved_at)
    distance_of_time_in_words(DateTime.current, retrieved_at + 30.minutes, include_seconds: true)
  end
end
