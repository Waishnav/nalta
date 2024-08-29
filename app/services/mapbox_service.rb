require 'net/http'
require 'json'

class MapboxService
  BASE_URL = 'https://api.mapbox.com/geocoding/v5/mapbox.places'.freeze
  ACCESS_TOKEN = 'pk.eyJ1IjoidmFpc2huYXY3NiIsImEiOiJjbTBjanVpdzkwM3p6Mmlxc25ha3lyZ21mIn0.vWhWfnAEsvZ2MUMRgo0u0w'.freeze

  def initialize
  end

  def fetch_destination_details(destination_name, country_name)
    encoded_place_name = URI.encode_www_form_component("#{destination_name}, #{country_name}")
    url = URI("#{BASE_URL}/#{encoded_place_name}.json?access_token=#{ACCESS_TOKEN}&types=place&limit=1")

    response = Net::HTTP.get_response(url)
    parse_response(response)
  end

  def fetch_places_details(destination, country_code, poi)
    encoded_place_name = URI.encode_www_form_component("#{@poi} in #{destination.name}")
    url = URI("#{BASE_URL}/#{encoded_place_name}.json?country=#{country_code}&access_token=#{ACCESS_TOKEN}&types=poi&limit=10&proximity=#{destination.longitude},#{destination.latitude}")

    response = Net::HTTP.get_response(url)
    parse_response(response)
  end

  private

  def parse_response(response)
    return [] unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    data['features']
  rescue JSON::ParserError
    []
  end
end
