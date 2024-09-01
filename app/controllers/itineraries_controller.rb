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

    destination, fetched_places = data_fetcher.call

    @places = Place.where(destination: destination)
               .joins(:point_of_interests)
               .where(point_of_interests: { category: interest_ids })
               .distinct

    puts "places: #{@places}"

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

  # 4hr each
  #
  #
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
      dawn: 2,
      morning: 2,
      afternoon: 4,
      evening: 2,
      night: 2
    }

    itinerary = []
    visited_places = Set.new

    def find_best_place_for_category(places, category, time_slot)
      # TODO: depending on location of previouly filled itinerary, we can filter places
      places.select { |place| place.place_best_times.map(&:best_time_to_visit).include?(time_slot.to_s) }
            .select { |place| place.point_of_interests.map(&:category).include?(category) }
            .sort_by { |place| -place.rating.to_f }
            #.sort_by { |place| -place.average_time_spent }
    end


    time_duration.each do |slot, duration|
      category_availablity = Hash[interests.map { |item| [item, true] }]
      i = 0

      increment_i = lambda do
        i += 1
        i = 0 if i >= interests.length
      end

      increment_till_next_available_interest = lambda do
        all_false = category_availablity.each_value.all? { |value| value == false }
        puts "catgory availablity: #{category_availablity}"

        if all_false
          i = -1
          return
        end

        increment_i.call()
        while category_availablity[interests[i]] == false
          increment_i.call()
        end
      end

      puts "#{slot} - #{duration}"

      while duration > 0 && i != -1
        puts "i: #{i}, duration: #{duration}"
        interest = interests[i]

        available_places = find_best_place_for_category(places, interest, slot)
        if available_places.length == 0
          puts "length 0 available place for #{interest} in #{slot}"
          category_availablity[interest] = false
          increment_till_next_available_interest.call()
          next
        end
        unvisited_place = available_places.find do |place|
          !visited_places.include?(place)
        end

        if unvisited_place.nil?
          puts "no unvisited"
          category_availablity[interest] = false
          increment_till_next_available_interest.call()
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
          puts "duratiton exceed #{interest}"
          category_availablity[interest] = false
        end

        increment_till_next_available_interest.call()
      end

      if slot.to_s == "dawn"
        itinerary << { break: "breakfast" }
      elsif slot.to_s == "morning"
        itinerary << { break: "lunch" }
      elsif slot.to_s == "evening"
        itinerary << { break: "dinner" }
      end
    end

    itinerary
  end
end
