class WeatherController < ApplicationController
  def home
    # root path.
  end
  def weather_for_zip
    @zip_code = ZipCode.find_or_initialize_by(weather_params)
    @weather_object = WeatherForZipCodeService.call(@zip_code)
    
    render :home
  end
  
  private
  
  def weather_params
    params.permit(:zip_code)
  end
end