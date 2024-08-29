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

    #data_fetcher = DataFetcherService.new(
    #  params[:destination],
    #  "India",
    #  params[:latitude],
    #  params[:longitude],
    #  params[:interest_ids]
    #)

    # Find or create the destination
    @destination = Destination.find_or_create_by(name: destination) do |dest|
      dest.latitude = latitude
      dest.longitude = longitude
    end

    # if destination is not found, we first fetch it from mapbox database through their API
    #@destination = data_fetcher.call

    # Filter places based on interests and location
    @places = Place.where(destination: @destination)
               .joins(:point_of_interests)
               .where(point_of_interests: { category: interest_ids })
               .distinct

    # Cluster places
    clustering_service = PlaceClusteringService.new(@places, num_days)
    @clustered_places = clustering_service.cluster

    interest_categories = interest_ids.map { |id| PointOfInterest.categories.key(id.to_i) }
    @itineraries = @clustered_places.map.with_index do |cluster, day|
      generate_and_assign_time_blocks(places: cluster, interests: interest_categories)
    end

    render json: { itineraries: @itineraries }
  end

  private

  # dawn = 6am - 8am
  ## breakfast = 8am - 9am
  # morning = 9am - 12pm
  ## lunch = 12pm - 1pm
  # afternoon = 1pm - 5pm
  # evening = 5pm - 7pm
  ## dinner = 7pm - 8pm
  # night = 8pm - 12am
  def generate_and_assign_time_blocks(places:, interests:)
    time_slots = {
      dawn: { start: Time.new(2000, 1, 1, 6, 0, 0), end: Time.new(2000, 1, 1, 8, 0, 0) },
      morning: { start: Time.new(2000, 1, 1, 9, 0, 0), end: Time.new(2000, 1, 1, 12, 0, 0) },
      afternoon: { start: Time.new(2000, 1, 1, 13, 0, 0), end: Time.new(2000, 1, 1, 17, 0, 0) },
      evening: { start: Time.new(2000, 1, 1, 17, 0, 0), end: Time.new(2000, 1, 1, 19, 0, 0) },
      night: { start: Time.new(2000, 1, 1, 20, 0, 0), end: Time.new(2000, 1, 1, 23, 59, 59) }
    }

    meals = {
      breakfast: { start: Time.new(2000, 1, 1, 8, 0, 0), end: Time.new(2000, 1, 1, 9, 0, 0) },
      lunch: { start: Time.new(2000, 1, 1, 12, 0, 0), end: Time.new(2000, 1, 1, 13, 0, 0) },
      dinner: { start: Time.new(2000, 1, 1, 19, 0, 0), end: Time.new(2000, 1, 1, 20, 0, 0) }
    }

    itinerary = []

    visited_place_id = Set.new
    visited_categories = Set.new

    # for each time slot, query places and then in these places array,
    # iterate over each interest and assign the place to visit and time slot in that time slot
    # we have to move to another interest after assigning atleast one place to each interest
    # we have to keep track of visited places

    def find_best_place(places, time_slot, visited_categories, available_time)
      places.select { |place| place.place_best_times.map(&:best_time_to_visit).include?(time_slot.to_s) }
            .select { |place| place.average_time_spent <= available_time }
            #.sort_by { |place| [visited_categories.intersect?(place.point_of_interests.pluck(:category)) ? 1 : 0, -place.average_time_spent] }
            .first
    end

    time_slots.each do |slot, time|
      slot_duration = (time[:end] - time[:start]) / 3600.0
      remaining_time = slot_duration

      while remaining_time > 0 && !places.empty?
        place = find_best_place(places, slot, visited_categories, remaining_time)
        break unless place

        visit_duration = [place.average_time_spent, remaining_time].min
        start_time = time[:start] + (slot_duration - remaining_time) * 3600
        end_time = start_time + visit_duration * 3600

        # Get all categories for the place and filter by user interests
        place_categories = place.point_of_interests.pluck(:category)
        relevant_categories = place_categories & interests

        itinerary << {
          place: place,
          start_time: start_time,
          end_time: end_time,
          category: place_categories
        }

        visited_categories.merge(relevant_categories)
        places.delete(place)
        remaining_time -= visit_duration
      end
    end

    meals.each do |meal, time|
      itinerary << {
        place: meal.to_s,
        start_time: time[:start],
        end_time: time[:end],
        category: meal.to_s
      }
    end

    itinerary.sort_by { |item| item[:start_time] }
  end
end
