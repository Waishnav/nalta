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
  console.log(selectedInterests)

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

  const renderForm = () => (
    <form
      onSubmit={() => {
        setActive((prev) => prev + 1);
      }}
      action="/itineraries" method="post"
      className="flex flex-col items-center gap-8 mb-8 max-w-[800px] w-full"
    >
      <input type="hidden" name="authenticity_token" value={authenticity_token} />
      {active === 1 && (
        <>
          <label htmlFor="destination" className="font-semibold text-4xl py-4">
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
          <label className="font-semibold text-4xl py-4">
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
          <label className="font-semibold text-4xl py-4">
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
          <Button color="teal.5" size="md">
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

  return (
    <MantineProvider>
      <div className="flex flex-col h-screen">
        <div className="flex justify-center mt-8">
          <Progress color="black" value={(active) * 100 / 3} w={900} />
        </div>
        <div className="flex flex-grow items-center justify-center">
          {renderForm()}
        </div>
      </div>
    </MantineProvider>
  );
}

export default CreateItenariesForm;
