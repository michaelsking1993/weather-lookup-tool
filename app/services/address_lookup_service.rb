# require 'uri'
# require 'net/http'

# NOTE: this service is for converting an address to a zip code. It is not complete. 
# This would allow us to enter in an actual address, convert it to a zip code using a Google Cloud API, 
# and then convert that zip code to a weather forecast. However, it turned out to be more involved of an implementation than I had time for.

# class AddressLookupService < ApplicationService
#
#   class AddressLookupApiError < StandardError; end
#
#   ADDRESS_API_URL = 'https://addressvalidation.googleapis.com/v1:validateAddress'
#   # see .env.sample for the following API key.
#   GOOGLE_CLOUD_API_KEY = ENV['GOOGLE_CLOUD_API_KEY']
#
#   def initialize(address)
#     @address = address
#   end
#
#   def call
#     addr_info = validate_address
#     debugger
#     puts 'hello'
#   rescue AddressLookupApiError => e
#     return { success: false, error: e.message }
#   end
#
#   private
#
#   def validate_address
#     uri = URI(ADDRESS_API_URL + '?key=' + GOOGLE_CLOUD_API_KEY)
#     body = {
#       address: {
#         address_lines: [@address]
#       }
#     }
#     # TODO: input body
#     response = Net::HTTP.get_response(uri)
#     parsed_body = JSON.parse(response.body)
#     if response.is_a?(Net::HTTPSuccess)
#       parsed_body
#     else
#       error_message = parsed_body&.[]('error')&.[]('message') || 'Unknown Error'
# 
#       raise AddressLookupApiError, error_message
#     end
#   end
# end
#