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
    fetch_places_for_destination(destination)
    destination
  end

  private

  def find_or_create_destination
    country = Country.find_by(name: @country_name)
    destination = Destination.find_by(name: @destination_name)

    unless destination
      puts "\n\nCreating destination '#{@destination_name}' with provided details."

      destination = Destination.create(
        name: @destination_name,
        country: country,
        latitude: @latitude,
        longitude: @longitude
      )
    end

    puts "\n\nDestination '#{destination.name}' found/created."
    destination
  end

  def fetch_places_for_destination(destination)
    @interest_ids.each do |interest|
      fetch_data_for_interest(destination, interest)
    end
  end

  def fetch_data_for_interest(destination, interest)
    places = destination.places.joins(:point_of_interests).where(point_of_interests: { category: interest })

    unless places.exists?
      puts "\n\nFetching data for interest '#{interest}' from the API."
      data = @mapbox_service.fetch_places_details(destination, "in", interest)
      save_to_db(destination, data) if data.present?
    end
  end

  def save_to_db(destination, data)
    data.each do |place_data|
      place = Place.find_or_create_by(
        destination: destination,
        name: place_data['text'],
        longitude: place_data['center'][0],
        latitude: place_data['center'][1]
      )

      mapbox_categories = place_data['properties']['category']&.split(', ') || []
      mapbox_categories.each do |category|
        category_downcase = category.downcase

        # Create PointOfInterest
        if PointOfInterest.categories.key?(category_downcase.to_sym)
          PointOfInterest.find_or_create_by(
            place: place,
            category: category_downcase
          )
          puts "Created PointOfInterest: #{category_downcase} for place: #{place.name}"
        end

        # Create PlaceBestTime
        best_times = determine_best_time(category_downcase)
        best_times.each do |best_time|
          PlaceBestTime.find_or_create_by(
            place: place,
            best_time_to_visit: best_time
          )
          puts "Created PlaceBestTime: #{best_time} for place: #{place.name}"
        end
      end
    end
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
    when :viewpoint
      [:morning, :evening]
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
end
