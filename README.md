# Nalta - Trip itineraries recommender

![image](https://github.com/user-attachments/assets/e962b61b-da59-4765-8ca9-6b5a257c7f80)

## Tech Stack and Architecture
1. **Ruby on Rails** - Monolith Full stack framework

2. **React** - Only used for writing UI, routing is handled by rails

3. **SQlite** - in server single file db


## Questinos that I asked during implementation?
1. Is this problem solvable without using ML model, Generative AI?
    - It turns out, we can with the simple and well structured db, so according to filter on user preference we can suggest different places.

2. What are key user preferences?
    - Destination
    - Categories or Point of Interest , example - Tourist places, Beaches etc
    - Trip duration
    - Budget of trip
    - Solo or with family

3. What can be our data source? is there any API available which let me access to this data for each and every destination in India?
  - Mapbox API - results are not good as we needed
  - Google Place API - results are good but it doesn't provide info about places according to budget, same goes with solo or family option
  - Ola Geocoding and Places API - didn't able to test it thoroughly cause of timelimit

4. Can SQLite be enough for this solution?
  - I have not stress test the db in production as of now. TODO: I'll update this section later
  - PostgreSQL has extensions like PostGIS, which lets you store the geolocation efficiently with some in-built methods to query places according to latitude, longitude
  - Yes PostgreSQL is best choice, but why not test SQLite? Either way we can migrate it later


 
