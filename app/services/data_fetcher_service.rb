class DataFetcherService
  def initialize(destination_name, country_name, latitude, longitude, interest_ids)
    @destination_name = destination_name
    @country_name = country_name
    @latitude = latitude
    @longitude = longitude
    @interest_ids = interest_ids
    @mapbox_service = MapboxService.new
  end

  def call
    destination = find_or_create_destination
    places = fetch_places_for_destination(destination)
    [destination, places]
  end

  private

  def find_or_create_destination
    country = Country.find_or_create_by(name: "India", code: "in")
    destination = Destination.find_by(name: @destination_name)

    unless destination
      puts "\n\nCreating destination '#{@destination_name}' with provided details."

      destination = Destination.find_or_create_by(
        name: @destination_name,
        country: country,
        latitude: @latitude,
        longitude: @longitude,
        avg_transportation_cost_per_km: 20.0,
        avg_food_cost_per_meal: 200.0
      )
    end

    puts "\n\nDestination '#{destination.name}' found/created."
    destination
  end

  def fetch_places_for_destination(destination)
    places = []
    @interest_ids.each do |interest_id|
      places.concat(fetch_data_for_interest(destination, PointOfInterest.categories.key(interest_id.to_i)))
    end
    places
  end

  def fetch_data_for_interest(destination, interest)
    places = destination.places.joins(:point_of_interests).where(point_of_interests: { category: interest })

    if places.empty?
      puts "\n\nFetching data for interest '#{interest}' from the API."
      data = fetch_from_google_places_api(destination, interest)
      places = save_to_db(destination, interest, data) if data.present?
    end

    places
  end

  def fetch_from_google_places_api(destination, interest)
    url = URI("https://places.googleapis.com/v1/places:searchText")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/json'
    request['X-Goog-Api-Key'] = 'AIzaSyBcskRDFKuE626CwoH-Jloy77QpzthnK90'
    request['X-Goog-FieldMask'] = 'places.displayName,places.id,places.location,places.primaryType,places.types,places.photos,places.rating'

    puts "#{interest.humanize}"
    request.body = { textQuery: "#{interest.humanize} in #{destination.name}, India" }.to_json

    response = http.request(request)
    data = JSON.parse(response.body)
  end

  def save_to_db(destination, interest, data)
    data['places'].map do |p|
      place = Place.find_by(name: p['displayName']['text'])

      unless place
      place = Place.create(
        destination: destination,
        name: p['displayName']['text'],
        longitude: p['location']['longitude'],
        latitude: p['location']['latitude'],
        rating: p['rating']
      )
      end

      if PointOfInterest.categories.key?(interest.to_sym)
        point_of_interest = PointOfInterest.find_or_create_by(
          place: place,
          category: interest
        )

        best_time_and_duration = determine_best_time_and_duration(interest)
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
end
