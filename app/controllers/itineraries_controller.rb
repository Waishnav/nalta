class ItinerariesController < ApplicationController
  def index
    @destinations = Destination.all
    @interests = Place.categories.keys
  end

  def create
    @destination = Destination.find(params[:destination])
    @interests = params[:interest_ids] || []

    # Filter places based on interests
    @places = @destination.places.where(category: @interests) if @interests.any?

    @itinerary = generate_and_assign_time_blocks(start_time: Time.new(2000, 1, 1, 9, 0, 0), end_time: Time.new(2000, 1, 1, 18, 0, 0), places: @places)

    render :results
  end

  private

  def itinerary_params
    params.require(:itinerary).permit(:destination, interest_ids: [])
  end

  def generate_and_assign_time_blocks(start_time:, end_time:, places:)
    itineraries = []
    current_time = start_time
    visited_places = Set.new

    while current_time < end_time
      next_place = places.find do |place|
        next if visited_places.include?(place.id)

        place_open = place.opening_hours <= current_time
        place_close = place.closing_hours >= (current_time + place.average_time_spent * 60)
        place_fits = (current_time + place.average_time_spent * 60) <= end_time

        place_open && place_close && place_fits
      end

      # loop should be break if no suitable place is found
      break unless next_place

      itineraries << {
        time_block: { start: current_time, end: current_time + next_place.average_time_spent * 60 },
        place: next_place,
        activities: next_place.activities
      }

      visited_places.add(next_place.id)
      current_time += next_place.average_time_spent * 60
    end
    itineraries
  end

end
