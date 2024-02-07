FactoryBot.define do
  factory :zip_code do
    zip_code { '12345' }
    weather_forecast { nil }
    weather_retrieved_at { nil }
  end
end