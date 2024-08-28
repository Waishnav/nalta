class ItinerariesController < ApplicationController
  def index
    @destinations = Destination.all
    @interests = PointOfInterest.categories.keys.map(&:humanize)
  end

  def create
    @destination = Destination.find(params[:destination])
    @interests = params[:interest_ids] || []
    @num_days = params[:num_days].to_i

    # Filter places based on interests
    @places = @destination.places.where(category: @interests) if @interests.any?

    # Cluster places
    clustering_service = PlaceClusteringService.new(@places, @num_days)
    @clustered_places = clustering_service.cluster
    #puts "Clustered places: #{@clustered_places}"

    @itineraries = @clustered_places.map.with_index do |cluster, day|
      generate_and_assign_time_blocks(
        start_time: Time.new(2000, 1, 1, 9, 0, 0),
        end_time: Time.new(2000, 1, 1, 18, 0, 0),
        lunch_time: { start: Time.new(2000, 1, 1, 12, 0, 0), end: Time.new(2000, 1, 1, 13, 0, 0) },
        dinner_time: { start: Time.new(2000, 1, 1, 18, 0, 0), end: Time.new(2000, 1, 1, 19, 0, 0) },
        places: cluster
      )
    end

    render :results
  end

  private

  def generate_and_assign_time_blocks(start_time:, end_time:, lunch_time:, dinner_time:, places:)
    itineraries = []
    current_time = start_time
    visited_places = Set.new

    while current_time < end_time
      # lunch time
      if current_time >= lunch_time[:start] && current_time < lunch_time[:end]
        itineraries << {
          time_block: { start: lunch_time[:start], end: lunch_time[:end] },
          break: 'Lunch Time'
        }
        current_time = lunch_time[:end]
        next
      end

      # dinner time
      if current_time >= dinner_time[:start] && current_time < dinner_time[:end]
        itineraries << {
          time_block: { start: dinner_time[:start], end: dinner_time[:end] },
          break: 'Dinner Time'
        }
        current_time = dinner_time[:end]
        next
      end
      next_place = places.find do |place|
        next if visited_places.include?(place.id)

        place_open = place.opening_hours <= current_time
        place_close = place.closing_hours >= (current_time + place.average_time_spent * 3600)
        place_fits = (current_time + place.average_time_spent * 3600) <= end_time

        place_open && place_close && place_fits
      end

      break unless next_place

      itineraries << {
        time_block: { start: current_time, end: current_time + next_place.average_time_spent * 3600 },
        place: next_place,
        activities: next_place.activities
      }

      visited_places.add(next_place.id)
      current_time += next_place.average_time_spent * 3600
    end
    itineraries
  end
end
