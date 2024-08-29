import { Button, Chip, Group, Input, MantineProvider, Progress, Select, Slider } from "@mantine/core";
import '@mantine/dates/styles.css';
import React, { useState } from "react";

const CreateItenariesForm = ({ authenticity_token, interests }) => {
  const [active, setActive] = useState(1);
  const [selectedDestination, setSelectedDestination] = useState("");
  const [latitude, setLatitude] = useState(0);
  const [longitude, setLongitude] = useState(0);
  const [duration, setDuration] = useState(1);
  const [selectedInterests, setSelectedInterests] = useState([]);
  const [suggestions, setSuggestions] = useState([]);
  const [showResults, setShowResults] = useState(false)
  const [itineraries, setItineraries] = useState([]);

  const MAPBOX_TOKEN = 'pk.eyJ1IjoidmFpc2huYXY3NiIsImEiOiJjbTBjZmY1eDgwMjVwMmpyNDJmMmZxMHI4In0.N3L7x-R9iV2yUwKMi3jXkw'; // Replace with your Mapbox access token

  const fetchMapboxSuggestions = async (query) => {
    try {
      const response = await fetch(`https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(query)}.json?access_token=${MAPBOX_TOKEN}&autocomplete=true&limit=5&country=in`);
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      const data = await response.json();
      console.log(data)
      return data.features.map(feature => ({
        value: feature.text,
        label: feature.text,
        latitude: feature.center[1],
        longitude: feature.center[0],
      }));
    } catch (error) {
      console.error("Error fetching data from Mapbox", error);
      return [];
    }
  };

  const handleSearch = async (query) => {
    if (query.length > 4) { // Trigger search only when input length is greater than 2
      const results = await fetchMapboxSuggestions(query);
      console.log(results)
      setSuggestions(results);
    } else {
      setSuggestions([]);
    }
  };

  const handleSelect = (value) => {
    const selectedFeature = suggestions.find(s => s.value === value);
    if (selectedFeature) {
      setSelectedDestination(selectedFeature.value);
      setLatitude(selectedFeature.latitude);
      setLongitude(selectedFeature.longitude);
    }
  };

  const handleSubmit = (event) => {
    event.preventDefault();
    if (active < 3) {
      setActive((prev) => prev + 1);
    } else {
      fetch('/itineraries', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': authenticity_token
        },

        body: JSON.stringify({
          destination: selectedDestination,
          latitude: latitude,
          longitude: longitude,
          interest_ids: selectedInterests,
          num_days: duration
        })
      })
        .then(response => response.json())
        .then(data => {
          setItineraries(data.itineraries);
          setActive((prev) => prev + 1);
          setShowResults(true);
        });
    }
  };

  const renderForm = () => (
    <form
      className="flex flex-col items-center gap-8 mb-8 max-w-[800px] w-full"
    >
      {active === 1 && (
        <>
          <label htmlFor="destination" className="font-semibold text-center text-4xl py-4">
            Where do you want to go?
          </label>
          <Select
            rightSection={<></>}
            size="xl"
            radius={"md"}
            w={800}
            placeholder="Example: Mumbai"
            onSearchChange={handleSearch}
            onChange={handleSelect}
            value={selectedDestination}
            data={suggestions}
            checkIconPosition="right"
            searchable
            required
          />
        </>
      )}

      {active === 2 && (
        <>
          <label className="font-semibold text-4xl text-center py-4">
            How many days of trip?
          </label>
          <Slider
            value={duration}
            onChange={setDuration}
            size="xl"
            color="black"
            marks={[
              { value: 1, label: "1 day trip" },
              { value: 2, label: "2 days trip" },
              { value: 3, label: "3 days trip" },
              { value: 4, label: "4 days trip" },
              { value: 5, label: "5 days trip" },
            ]}
            min={1}
            max={5}
            radius={"md"}
            w={800}
          />
        </>
      )}

      {active === 3 && (
        <>
          <label className="font-semibold text-4xl text-center py-4">
            Tell us what you’re interested in
          </label>
          <Chip.Group
            multiple
            value={selectedInterests}
            onChange={setSelectedInterests}
          >
            <Group justify="center" mt="md">
              {
                interests.map((interest, index) => (
                  <Chip
                    key={index}
                    variant="outline"
                    size="md"
                    color="teal.5"
                    value={index.toString()}
                    onClick={() => {
                      if (selectedInterests.includes(index)) {
                        setSelectedInterests(selectedInterests.filter((item) => item !== index));
                      } else {
                        setSelectedInterests([...selectedInterests, index]);
                      }
                    }}
                  >
                    {interest}
                  </Chip>
                ))
              }
            </Group>
          </Chip.Group>
        </>
      )}

      <div className="flex w-full justify-between gap-4 mt-8">
        <Button
          size="md"
          variant="outline"
          radius={"md"}
          color="teal.5"
          onClick={() => setActive((prev) => Math.max(prev - 1, 1))}
        >
          Back
        </Button>
        {active === 3 ? (
          <Button onClick={handleSubmit} color="teal.5" size="md">
            Submit
          </Button>
        ) : (
          <Button
            size="md"
            variant="filled"
            radius={"md"}
            color="teal.5"
            onClick={() => setActive((prev) => prev + 1)}
          >
            Next
          </Button>
        )}
      </div>
    </form>
  )

  // itineraries contains the list of itineraries of each day array of array(days) of places
  const renderResults = () => (
  <>
    <div className="flex flex-col items-center gap-8 mb-8 max-w-[800px] w-full">
      <label className="font-semibold text-4xl text-center py-4">
        Here are some itineraries for you
      </label>

      {itineraries.map((day, dayIndex) => (
        <div key={dayIndex} className="flex flex-col items-center gap-8 mb-8 max-w-[800px] w-full">
          <label className="font-semibold text-2xl text-center py-4">
            Day {dayIndex + 1}
          </label>
          
          <table className="table-auto w-full">
            <thead>
              <tr>
                <th className="px-4 py-2 text-left">Place</th>
                <th className="px-4 py-2 text-left">Start Time</th>
                <th className="px-4 py-2 text-left">End Time</th>
              </tr>
            </thead>
            <tbody>
              {day.map((activity, activityIndex) => (
                <tr key={activityIndex}>
                  <td className="border px-4 py-2">
                    {typeof activity.place === 'string' ? activity.place : activity.place.name}
                  </td>
                  <td className="border px-4 py-2">
                    {new Date(activity.start_time).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                  </td>
                  <td className="border px-4 py-2">
                    {new Date(activity.end_time).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ))}
    </div>
  </>
);

  return (
    <MantineProvider>
      <div className="flex flex-col h-screen">
        {showResults ? (
          <>
            <div className="flex flex-grow items-center mt-8 justify-center">
              {renderResults()}
            </div>
          </>
        ) : (
          <>
            <div className="flex justify-center mt-8">
              <Progress color="black" value={(active) * 100 / 3} w={900} />
            </div>
            <div className="flex flex-grow items-center justify-center">
              {renderForm()}
            </div>
          </>
        )}
      </div>
    </MantineProvider>
  );
}

export default CreateItenariesForm;
