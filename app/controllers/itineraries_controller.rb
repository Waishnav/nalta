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

    # Find or create the destination
    @destination = Destination.find_or_create_by(name: destination) do |dest|
      dest.latitude = latitude
      dest.longitude = longitude
    end

    # Filter places based on interests and location
    @places = Place.where(destination: @destination)
               .joins(:point_of_interests)
               .where(point_of_interests: { category: interest_ids })
               .distinct

    # Cluster places
    clustering_service = PlaceClusteringService.new(@places, num_days)
    @clustered_places = clustering_service.cluster

    @itineraries = @clustered_places.map.with_index do |cluster, day|
      generate_and_assign_time_blocks(places: cluster)
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

  def generate_and_assign_time_blocks(places:)
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
    visited_categories = Set.new

    # Helper method to find the best place for a given time slot
    def find_best_place(places, time_slot, visited_categories, available_time)
      places.select { |place| place.place_best_times.map(&:best_time_to_visit).include?(time_slot.to_s) }
            .select { |place| place.average_time_spent <= available_time }
            .sort_by { |place| [visited_categories.include?(place.point_of_interests.first.category) ? 1 : 0, -place.average_time_spent] }
            .first
    end

    # Assign places to time slots
    time_slots.each do |slot, time|
      slot_duration = (time[:end] - time[:start]) / 3600.0 # Convert to hours
      remaining_time = slot_duration

      while remaining_time > 0 && !places.empty?
        place = find_best_place(places, slot, visited_categories, remaining_time)
        break unless place

        visit_duration = [place.average_time_spent, remaining_time].min
        start_time = time[:start] + (slot_duration - remaining_time) * 3600
        end_time = start_time + visit_duration * 3600

        itinerary << {
          place: place,
          start_time: start_time,
          end_time: end_time,
          category: place.point_of_interests.first.category
        }

        visited_categories.add(place.point_of_interests.first.category)
        places.delete(place)
        remaining_time -= visit_duration
      end
    end

    # Add meals to the itinerary
    meals.each do |meal, time|
      itinerary << {
        place: "Find a place for #{meal}",
        start_time: time[:start],
        end_time: time[:end],
        category: meal
      }
    end

    itinerary.sort_by { |item| item[:start_time] }
  end
end
