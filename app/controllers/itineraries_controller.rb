class ItinerariesController < ApplicationController
  def index
    @destinations = Destination.all
  end

  def create
  end

  private

  def itinerary_params 
    params.require(:itinerary).permit(:name, :description, :start_date, :end_date, :destination_id)
  end
end
