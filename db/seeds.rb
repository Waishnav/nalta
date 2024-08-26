# Activities category enum : { adventure: 0, cultural: 1, fun: 2, relaxation: 3, other: 4 }

# Places category enum : { hotel: 0, restaurant: 1, attraction: 2, landmark: 3, park: 4, museum: 5, other: 6 }

# Mumbai
Destination.create(name: "Mumbai", country: "India", latitude: 19.076090, longitude: 72.877426, avg_transportation_cost_per_km: 20.0, avg_food_cost_per_meal: 200.0)

# Places in Mumbai
Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Gateway of India", category: :landmark, average_time_spent: 2, opening_hours: "09:00:00", closing_hours: "21:00:00", min_cost: 0.0, max_cost: 0.0, latitude: 18.9220, longitude: 72.8347)
Activity.create(place: Place.find_by(name: "Gateway of India"), name: "Boat Ride", category: :adventure, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Gateway of India"), name: "Photography", category: :fun, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Gateway of India"), name: "Shopping", category: :fun, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Gateway of India"), name: "Food", category: :fun, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Marine Drive", category: :attraction, average_time_spent: 2, opening_hours: "00:00:00", closing_hours: "23:59:59", min_cost: 0.0, max_cost: 0.0, latitude: 18.9402, longitude: 72.8213)
Activity.create(place: Place.find_by(name: "Marine Drive"), name: "Photography", category: :fun, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Marine Drive"), name: "Food", category: :fun, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Marine Drive"), name: "Shopping", category: :fun, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Marine Drive"), name: "Relaxation", category: :fun, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Juhu Beach", category: :attraction, average_time_spent: 1, opening_hours: "00:00:00", closing_hours: "23:59:59", min_cost: 0.0, max_cost: 0.0, latitude: 19.0974, longitude: 72.8261)
Activity.create(place: Place.find_by(name: "Juhu Beach"), name: "Photography", category: :fun, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Juhu Beach"), name: "Food", category: :fun, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Juhu Beach"), name: "Shopping", category: :fun, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Siddhivinayak Temple", category: :landmark, average_time_spent: 1, opening_hours: "05:30:00", closing_hours: "21:00:00", min_cost: 0.0, max_cost: 0.0, latitude: 19.0176, longitude: 72.8309)
Activity.create(place: Place.find_by(name: "Siddhivinayak Temple"), name: "Prayer", category: :cultural, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Haji Ali Dargah", category: :landmark, average_time_spent: 0.5, opening_hours: "05:30:00", closing_hours: "22:00:00", min_cost: 0.0, max_cost: 0.0, latitude: 18.9829, longitude: 72.8106)
Activity.create(place: Place.find_by(name: "Haji Ali Dargah"), name: "Prayer", category: :cultural, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Chhatrapati Shivaji Maharaj Terminus", category: :landmark, average_time_spent: 0.5, opening_hours: "00:00:00", closing_hours: "23:59:59", min_cost: 0.0, max_cost: 0.0, latitude: 18.9402, longitude: 72.8359)
Activity.create(place: Place.find_by(name: "Chhatrapati Shivaji Maharaj Terminus"), name: "Photography", category: :fun, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Chhatrapati Shivaji Maharaj Terminus"), name: "Shopping", category: :fun, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Elephanta Caves", category: :attraction, average_time_spent: 1.5, opening_hours: "09:00:00", closing_hours: "17:30:00", min_cost: 0.0, max_cost: 0.0, latitude: 18.9647, longitude: 72.9314)
Activity.create(place: Place.find_by(name: "Elephanta Caves"), name: "Photography", category: :fun, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Elephanta Caves"), name: "Shopping", category: :fun, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Elephanta Caves"), name: "Exploration", category: :adventure, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Chor Bazaar", category: :attraction, average_time_spent: 1, opening_hours: "11:00:00", closing_hours: "19:30:00", min_cost: 0.0, max_cost: 0.0, latitude: 18.9668, longitude: 72.8258)
Activity.create(place: Place.find_by(name: "Chor Bazaar"), name: "Shopping", category: :fun, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Sanjay Gandhi National Park", category: :park, average_time_spent: 1, opening_hours: "07:30:00", closing_hours: "18:30:00", min_cost: 0.0, max_cost: 0.0, latitude: 19.2148, longitude: 72.9106)
Activity.create(place: Place.find_by(name: "Sanjay Gandhi National Park"), name: "Photography", category: :fun, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Sanjay Gandhi National Park"), name: "Exploration", category: :adventure, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Worli Sea Face", category: :attraction, average_time_spent: 1, opening_hours: "00:00:00", closing_hours: "23:59:59", min_cost: 0.0, max_cost: 0.0, latitude: 19.0190, longitude: 72.8154)
Activity.create(place: Place.find_by(name: "Worli Sea Face"), name: "Photography", category: :fun, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Worli Sea Face"), name: "Relaxation", category: :fun, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Worli Sea Face"), name: "Food", category: :fun, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Global Vipassana Pagoda", category: :landmark, average_time_spent: 0.5, opening_hours: "09:00:00", closing_hours: "19:00:00", min_cost: 0.0, max_cost: 0.0, latitude: 19.2315, longitude: 72.8100)
Activity.create(place: Place.find_by(name: "Global Vipassana Pagoda"), name: "Meditation", category: :relaxation, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Nehru Science Centre", category: :museum, average_time_spent: 1, opening_hours: "10:00:00", closing_hours: "18:00:00", min_cost: 0.0, max_cost: 0.0, latitude: 18.9940, longitude: 72.8225)
Activity.create(place: Place.find_by(name: "Nehru Science Centre"), name: "Exploration", category: :adventure, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Colaba Causeway", category: :attraction, average_time_spent: 1, opening_hours: "10:00:00", closing_hours: "21:00:00", min_cost: 0.0, max_cost: 0.0, latitude: 18.9166, longitude: 72.8323)
Activity.create(place: Place.find_by(name: "Colaba Causeway"), name: "Shopping", category: :fun, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Crawford Market", category: :attraction, average_time_spent: 1, opening_hours: "10:00:00", closing_hours: "20:00:00", min_cost: 0.0, max_cost: 0.0, latitude: 18.9503, longitude: 72.8332)
Activity.create(place: Place.find_by(name: "Crawford Market"), name: "Shopping", category: :fun, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "Phoenix Market City", category: :attraction, average_time_spent: 1, opening_hours: "11:00:00", closing_hours: "22:00:00", min_cost: 0.0, max_cost: 0.0, latitude: 19.0872, longitude: 72.8792)
Activity.create(place: Place.find_by(name: "Phoenix Market City"), name: "Shopping", category: :fun, cost: 0.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "Phoenix Market City"), name: "Food", category: :fun, cost: 0.0, average_time_spent: 0.5)

Place.create(destination: Destination.find_by(name: "Mumbai"), name: "High Street Phoenix", category: :attraction, average_time_spent: 1, opening_hours: "11:00:00", closing_hours: "22:00:00", min_cost: 0.0, max_cost: 0.0, latitude: 18.9937, longitude: 72.8208)
Activity.create(place: Place.find_by(name: "High Street Phoenix"), name: "Shopping", category: :fun, cost: 200.0, average_time_spent: 0.5)
Activity.create(place: Place.find_by(name: "High Street Phoenix"), name: "Food", category: :fun, cost: 300.0, average_time_spent: 0.5)
