india = Country.find_or_create_by(name: "India", code: "in")
puts india.inspect

require 'net/http'
require 'json'

MAPBOX_ACCESS_TOKEN = 'pk.eyJ1IjoidmFpc2huYXY3NiIsImEiOiJjbTBjanVpdzkwM3p6Mmlxc25ha3lyZ21mIn0.vWhWfnAEsvZ2MUMRgo0u0w'
GOOGLE_PLACES_API_KEY = 'AIzaSyBcskRDFKuE626CwoH-Jloy77QpzthnK90'

def fetch_destination_details(destination_name, country)
  encoded_place_name = URI.encode_www_form_component("#{destination_name}, #{country}")
  url = URI("https://api.mapbox.com/geocoding/v5/mapbox.places/#{encoded_place_name}.json?access_token=#{MAPBOX_ACCESS_TOKEN}&types=place")

  response = Net::HTTP.get_response(url)
  data = JSON.parse(response.body)

  if data['features'].empty?
    puts "No results found for #{destination_name}"
    return nil
  end

  feature = data['features'][0]
  {
    name: feature['text'],
    longitude: feature['center'][0],
    latitude: feature['center'][1],
    country: feature['context'].find { |c| c['id'].start_with?('country') }&.dig('text')
  }
end

def determine_best_time(category)
  case category.to_sym
  when :beach, :lake
    [:dawn, :morning, :evening]
  when :shopping_mall
    [:afternoon, :evening]
  when :art_gallery, :museum
    [:afternoon]
  when :landscaping, :park, :nature_reserve
    [:morning, :afternoon]
  when :nightlife, :nightclub
    [:night]
  when :entertainment
    [:afternoon, :evening, :night]
  when :tourist_attraction, :historic_site, :monument
    [:morning, :afternoon]
  when :temple
    [:morning, :evening]
  when :art
    [:morning, :afternoon, :evening]
  when :animal_shelter, :zoo, :aquarium
    [:morning, :afternoon]
  when :water_park
    [:afternoon]
  when :climbing, :cave
    [:morning, :afternoon]
  when :waterfall
    [:morning, :afternoon]
  else
    [:morning, :afternoon, :evening]
  end
end


def determine_best_time_and_duration(category)
  case category.to_sym
  when :beach, :lake
    { best_times: [:dawn, :evening], average_time_spent: 1.5 }
  when :shopping_mall
    { best_times: [:afternoon, :evening], average_time_spent: 2.0 }
  when :art_gallery, :museum
    { best_times: [:afternoon], average_time_spent: 1.5 }
  when :park, :nature_reserve
    { best_times: [:morning, :afternoon], average_time_spent: 1.5 }
  when :nightlife
    { best_times: [:night], average_time_spent: 2.0 }
  when :entertainment
    { best_times: [:afternoon, :evening, :night], average_time_spent: 2.5 }
  when :tourist_attraction, :historic_site, :monument
    { best_times: [:morning, :afternoon], average_time_spent: 1.5 }
  when :religous_places
    { best_times: [:morning, :evening], average_time_spent: 1.0 }
  when :zoo, :aquarium
    { best_times: [:morning, :afternoon], average_time_spent: 2.0 }
  when :water_park
    { best_times: [:afternoon], average_time_spent: 4.0 }
  when :hiking, :cave
    { best_times: [:morning, :afternoon], average_time_spent: 2.5 }
  when :waterfall
    { best_times: [:morning, :afternoon], average_time_spent: 1.5 }
  else
    { best_times: [:morning, :afternoon, :evening], average_time_spent: 1.0 }
  end
end

def fetch_places_details(destination, country, poi)
  url = URI("https://places.googleapis.com/v1/places:searchText")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(url)
  request['Content-Type'] = 'application/json'
  request['X-Goog-Api-Key'] = GOOGLE_PLACES_API_KEY
  request['X-Goog-FieldMask'] = 'places.displayName,places.id,places.location,places.primaryType,places.types,places.photos,places.rating'

  puts "#{poi.humanize}"
  request.body = { textQuery: "#{poi.humanize} in #{destination.name}, #{country.name}" }.to_json

  response = http.request(request)
  data = JSON.parse(response.body)

  data['places'].map do |p|
    place = Place.find_or_create_by(
      destination: destination,
      name: p['displayName']['text'],
      longitude: p['location']['longitude'],
      latitude: p['location']['latitude'],
    )

    if PointOfInterest.categories.key?(poi.to_sym)
      point_of_interest = PointOfInterest.find_or_create_by(
        place: place,
        category: poi
      )

      best_time_and_duration = determine_best_time_and_duration(poi)
      # Update the place's average_time_spent if it's not set or if the new value is greater
      if place.average_time_spent.nil? || best_time_and_duration[:average_time_spent] > place.average_time_spent
        place.update(average_time_spent: best_time_and_duration[:average_time_spent])
      end

      best_time_and_duration[:best_times].each do |best_time|
        PlaceBestTime.find_or_create_by(
          place: place,
          best_time_to_visit: best_time
        )
      end
    end

    place
  end
end

# Destinations
destinations = [
  { name: "Mumbai", country: "India" },
  { name: "New Delhi", country: "India" },
  { name: "Pune", country: "India" },
  #{ name: "Nagpur", country: "India" },
  { name: "Goa", country: "India" },
  #{ name: "Jaipur", country: "India" },
  { name: "Agra", country: "India" },
  #{ name: "Kolkata", country: "India" },
  #{ name: "Chennai", country: "India" },
  { name: "Bengaluru", country: "India" },
  #{ name: "Hyderabad", country: "India" },
]
categories = PointOfInterest.categories.keys.map(&:to_s)

destinations.each do |d|
  details = fetch_destination_details(d[:name], d[:country])
  next if details.nil?

  dest = Destination.find_or_create_by(
    name: d[:name],
    country: india,
    latitude: details[:latitude],
    longitude: details[:longitude],
    avg_transportation_cost_per_km: 20.0,
    avg_food_cost_per_meal: 200.0
  )

  puts "Created destination: #{dest.name}"

  # array of categories or point of interests
  # iteration over these categories and fetching place details and storing it the places in our db
  categories.each do |category|
    places = fetch_places_details(dest, india, category)
    puts "  Found #{places.length} places for category: #{category}"
  end
end

puts "Destination and place creation completed."
