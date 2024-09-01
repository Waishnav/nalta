class ItinerariesController < ApplicationController
  def index
    @interests = PointOfInterest.categories.keys.map(&:humanize)
  end

  def create
    destination = params[:destination]
    latitude = params[:latitude]
    longitude = params[:longitude]
    interest_ids = params[:interest_ids]
    num_days = params[:num_days].to_i

    data_fetcher = DataFetcherService.new(
      params[:destination],
      "India",
      params[:latitude],
      params[:longitude],
      params[:interest_ids]
    )

    destination, @places = data_fetcher.call

    # Cluster places based on location
    clustering_service = PlaceClusteringService.new(@places, num_days)
    @clustered_places = clustering_service.cluster

    interest_categories = interest_ids.map { |id| PointOfInterest.categories.key(id.to_i) }
    @itineraries = @clustered_places.map.with_index do |cluster, day|
      generate_and_assign_time_blocks(places: cluster, interests: interest_categories)
    end

    render json: { itineraries: @itineraries }
  end

  private

  # dawn = 6am - 8am -> 7:30 - 8:30
  ## breakfast = 8am - 9am
  # morning = 9am - 12pm
  ## lunch = 12pm - 1pm
  # afternoon = 1pm - 5pm
  # evening = 5pm - 7pm
  ## dinner = 7pm - 8pm
  # night = 8pm - 12am

  def generate_and_assign_time_blocks(places:, interests:)
    time_duration = {
      dawn: 2, morning: 2, afternoon: 4, evening: 2, night: 2
    }

    # Preprocess places data
    places_by_category_and_time = preprocess_places(places, interests)

    itinerary = []
    visited_places = Set.new

    def find_best_place_for_category(places_data, category, time_slot, visited_places)
      places_data[category][time_slot].find { |place| !visited_places.include?(place) }
    end

    time_duration.each do |slot, duration|
      category_availability = Hash[interests.map { |item| [item, true] }]
      i = 0

      increment_i = lambda do
        i += 1
        i = 0 if i >= interests.length
      end

      increment_till_next_available_interest = lambda do
        all_false = category_availability.values.all?(false)

        if all_false
          i = -1
          return
        end

        increment_i.call
        while category_availability[interests[i]] == false
          increment_i.call
        end
      end

      while duration > 0 && i != -1
        interest = interests[i]

        unvisited_place = find_best_place_for_category(places_by_category_and_time, interest, slot, visited_places)

        if unvisited_place.nil?
          category_availability[interest] = false
          increment_till_next_available_interest.call
          next
        end

        if duration >= unvisited_place.average_time_spent
          itinerary << {
            place: unvisited_place,
            category: unvisited_place.point_of_interests.map(&:category)
          }

          visited_places.add(unvisited_place)
          duration -= unvisited_place.average_time_spent
        else
          category_availability[interest] = false
        end

        increment_till_next_available_interest.call
      end

      itinerary << { break: get_break_for_slot(slot) } if get_break_for_slot(slot)
    end

    itinerary
  end

  def preprocess_places(places, interests)
    places_data = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = [] } }

    places.each do |place|
      place.place_best_times.each do |best_time|
        slot = best_time.best_time_to_visit.to_sym
        place.point_of_interests.each do |poi|
          if interests.include?(poi.category)
            places_data[poi.category][slot] << place
          end
        end
      end
    end

    # Sort places by rating for each category and time slot
    places_data.each do |category, slots|
      slots.each do |slot, place_list|
        slots[slot] = place_list.sort_by { |place| -place.rating.to_f }
      end
    end

    places_data
  end

  def get_break_for_slot(slot)
    case slot
    when :dawn then "breakfast"
    when :morning then "lunch"
    when :evening then "dinner"
    else nil
    end
  end
end
