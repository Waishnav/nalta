# Activities category enum : { adventure: 0, cultural: 1, fun: 2, relaxation: 3, other: 4 }

# Places category enum : { hotel: 0, restaurant: 1, attraction: 2, landmark: 3, park: 4, museum: 5, other: 6 }

# Mumbai
#Destination.create(name: "Mumbai", country: "India", latitude: 19.076090, longitude: 72.877426, avg_transportation_cost_per_km: 20.0, avg_food_cost_per_meal: 200.0)
#
## Places in Mumbai
#Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Gateway of India", category: :landmark, average_time_spent: 2, opening_hours: "09:00:00", closing_hours: "21:00:00", min_cost: 0.0, max_cost: 0.0, latitude: 18.9220, longitude: 72.8347)
#Activity.create(place: Place.find_by(name: "Gateway of India"), name: "Boat Ride", category: :adventure, cost: 0.0, average_time_spent: 0.5)
#Activity.create(place: Place.find_by(name: "Gateway of India"), name: "Photography", category: :fun, cost: 0.0, average_time_spent: 0.5)
#Activity.create(place: Place.find_by(name: "Gateway of India"), name: "Shopping", category: :fun, cost: 0.0, average_time_spent: 0.5)
#Activity.create(place: Place.find_by(name: "Gateway of India"), name: "Food", category: :fun, cost: 0.0, average_time_spent: 0.5)
#
#Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Marine Drive", category: :attraction, average_time_spent: 2, opening_hours: "00:00:00", closing_hours: "23:59:59", min_cost: 0.0, max_cost: 0.0, latitude: 18.9402, longitude: 72.8213)
#Activity.create(place: Place.find_by(name: "Marine Drive"), name: "Photography", category: :fun, cost: 0.0, average_time_spent: 0.5)
#Activity.create(place: Place.find_by(name: "Marine Drive"), name: "Food", category: :fun, cost: 0.0, average_time_spent: 0.5)
#Activity.create(place: Place.find_by(name: "Marine Drive"), name: "Shopping", category: :fun, cost: 0.0, average_time_spent: 0.5)
#Activity.create(place: Place.find_by(name: "Marine Drive"), name: "Relaxation", category: :fun, cost: 0.0, average_time_spent: 0.5)

india = Country.find_or_create_by(name: "India", code: "in")
puts india.inspect

require 'net/http'
require 'json'

MAPBOX_ACCESS_TOKEN = 'pk.eyJ1IjoidmFpc2huYXY3NiIsImEiOiJjbTBjanVpdzkwM3p6Mmlxc25ha3lyZ21mIn0.vWhWfnAEsvZ2MUMRgo0u0w'

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
    [:morning, :evening]
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
    { best_times: [:morning, :evening], average_time_spent: 1.5 }
  when :shopping_mall
    { best_times: [:afternoon, :evening], average_time_spent: 2.0 }
  when :art_gallery, :museum
    { best_times: [:afternoon], average_time_spent: 1.5 }
  when :park, :nature_reserve
    { best_times: [:morning, :afternoon], average_time_spent: 1.5 }
  when :nightlife, :nightclub
    { best_times: [:night], average_time_spent: 2.0 }
  when :entertainment
    { best_times: [:afternoon, :evening, :night], average_time_spent: 2.5 }
  when :tourist_attraction, :historic_site, :monument
    { best_times: [:morning, :afternoon], average_time_spent: 2.0 }
  when :temple
    { best_times: [:morning, :evening], average_time_spent: 1.0 }
  when :art
    { best_times: [:morning, :afternoon, :evening], average_time_spent: 1.0 }
  when :animal_shelter, :zoo, :aquarium
    { best_times: [:morning, :afternoon], average_time_spent: 2.0 }
  when :water_park
    { best_times: [:afternoon], average_time_spent: 4.0 }
  when :climbing, :cave
    { best_times: [:morning, :afternoon], average_time_spent: 2.5 }
  when :waterfall
    { best_times: [:morning, :afternoon], average_time_spent: 1.5 }
  else
    { best_times: [:morning, :afternoon, :evening], average_time_spent: 1.0 }
  end
end

def fetch_places_details(destination, country, poi)
  encoded_place_name = URI.encode_www_form_component("#{poi} in #{destination.name}")
  url = URI("https://api.mapbox.com/geocoding/v5/mapbox.places/#{encoded_place_name}.json?country=#{country.code}&access_token=#{MAPBOX_ACCESS_TOKEN}&types=poi&limit=10&proximity=#{destination.longitude},#{destination.latitude}")

  response = Net::HTTP.get_response(url)
  data = JSON.parse(response.body)

  if data['features'].empty?
    puts "No results found for #{poi} in #{destination.name}"
    return []
  end

  data['features'].map do |feature|
    place = Place.find_or_create_by(
      destination: destination,
      name: feature['text'],
      longitude: feature['center'][0],
      latitude: feature['center'][1],
    )

    # renamed categories in our db
    category_mapping = {
      'tourism' => 'tourist_attraction',
      'attraction' => 'tourist_attraction',
    }

    # saving each category in PointOfInterest table
    mapbox_categories = feature['properties']['category']&.split(', ') || []
    mapbox_categories.each do |category|
      category_downcase = category.downcase
      mapped_category = category_mapping[category_downcase] || category_downcase

      if PointOfInterest.categories.key?(mapped_category.to_sym)
        point_of_interest = PointOfInterest.find_or_create_by(
          place: place,
          category: mapped_category
        )

        best_time_and_duration = determine_best_time_and_duration(mapped_category)
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
    end

    place
  end
end

# Destinations
destinations = [
  #{ name: "Mumbai", country: "India" },
  { name: "Mumbai City", country: "India" },
  #{ name: "New Delhi", country: "India" },
  #{ name: "Pune", country: "India" },
  #{ name: "Nagpur", country: "India" },
  #{ name: "Goa", country: "India" },
  #{ name: "Jaipur", country: "India" },
  #{ name: "Agra", country: "India" },
  #{ name: "Kolkata", country: "India" },
  #{ name: "Chennai", country: "India" },
  #{ name: "Bengaluru", country: "India" },
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
