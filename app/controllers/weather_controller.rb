class WeatherController < ApplicationController
  def home
    # root path.
  end
  
  def weather_for_zip
    @zip_code = ZipCode.find_or_initialize_by(weather_params)
    
    # TODO: store this object in Redis in the future, ex:
    #   @weather_object = with_cache("weather_for_#{@zip_code}", 30.minutes) { WeatherForZipCodeService.call(@zip_code) }
    @weather_object = WeatherForZipCodeService.call(@zip_code)
    
    render :home
  end
  
  private
  
  def weather_params
    params.permit(:zip_code)
  end
end