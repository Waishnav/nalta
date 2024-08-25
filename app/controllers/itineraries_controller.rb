class ItinerariesController < ApplicationController
  def index
    @destinations = Destination.all
  end

  def create
    @itinerary = Itinerary.new(itinerary_params)
    if @itinerary.save
      redirect_to @itinerary, notice: 'Itinerary created successfully.'
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def itinerary_params
    params.require(:itinerary).permit(:destination_id, :duration, :interest, :budget)
  end
end
