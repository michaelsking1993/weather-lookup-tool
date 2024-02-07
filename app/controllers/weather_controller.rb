class WeatherController < ApplicationController
  def home
  end
  def weather_for_zip
    @zip_code = params[:zip_code]
    @weather_object = ZipCodeToWeatherService.call(@zip_code)
    render :home
  end
end