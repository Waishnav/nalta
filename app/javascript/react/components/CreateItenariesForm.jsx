import { Badge, Button, Chip, Group, Loader, MantineProvider, Progress, Rating, SegmentedControl, Select, Slider, Text, Timeline } from "@mantine/core";
import React, { useEffect, useRef, useState } from "react";
import ItineraryMap from "./Map";
import { MapPinIcon, UtensilsIcon } from "lucide-react";
const DEBOUNCE_DELAY = 200;

const CreateItenariesForm = ({ authenticity_token, interests }) => {
  const [active, setActive] = useState(1);
  const [selectedDestination, setSelectedDestination] = useState("");
  const [latitude, setLatitude] = useState(0);
  const [longitude, setLongitude] = useState(0);
  const [duration, setDuration] = useState(1);
  const [selectedInterests, setSelectedInterests] = useState([]);
  const [interestError, setInterestError] = useState(false)
  const [suggestions, setSuggestions] = useState([]);
  const [isFetchingSuggestions, setIsFetchingSuggestions] = useState(false);
  const [showResults, setShowResults] = useState(null)
  const [isFetching, setIsFetching] = useState(false)
  const [itineraries, setItineraries] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [isValidDestination, setIsValidDestination] = useState(false)

  const abortControllerRef = useRef(null);

  const MAPBOX_TOKEN = 'pk.eyJ1IjoidmFpc2huYXY3NiIsImEiOiJjbTBjZmY1eDgwMjVwMmpyNDJmMmZxMHI4In0.N3L7x-R9iV2yUwKMi3jXkw'; // Replace with your Mapbox access token

  const fetchMapboxSuggestions = async (query) => {
    if (abortControllerRef.current) {
      abortControllerRef.current.abort();
    }

    abortControllerRef.current = new AbortController();
    const { signal } = abortControllerRef.current;

    try {
      const response = await fetch(
        `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(query)}.json?access_token=${MAPBOX_TOKEN}&autocomplete=true&limit=5&country=in`,
        { signal }
      );

      if (!response.ok) {
        throw new Error('Network response was not ok');
      }

      const data = await response.json();

      const uniqueFeatures = new Set();
      const suggestions = data.features.reduce((acc, feature) => {
        const value = feature.text;
        if (!uniqueFeatures.has(value)) {
          uniqueFeatures.add(value);
          acc.push({
            value: value,
            label: value,
            latitude: feature.center[1],
            longitude: feature.center[0],
          });
        }
        return acc;
      }, []);

      return suggestions;

    } catch (error) {
      console.error("Error fetching data from Mapbox", error);
      return [];
    }
  };

  useEffect(() => {
    setIsFetchingSuggestions(false);
  }, [suggestions]);

  useEffect(() => {
    const timeoutId = setTimeout(() => {
      if (searchQuery.length > 2) {
        setIsFetchingSuggestions(true);
        fetchMapboxSuggestions(searchQuery).then(setSuggestions);
      }
    }, DEBOUNCE_DELAY);

    return () => {
      clearTimeout(timeoutId);
      // Cancel any ongoing request when the component unmounts or when the effect re-runs
      if (abortControllerRef.current) {
        abortControllerRef.current.abort();
      }
    };
  }, [searchQuery]);

  useEffect(() => {
    // Validate selected destination against suggestions
    const isValid = suggestions.some(suggestion => suggestion.value === selectedDestination);
    setIsValidDestination(isValid);
  }, [selectedDestination, suggestions]);

  const handleSearch = async (query) => {
    setSearchQuery(query);
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
      setIsFetching(true);
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
          setIsFetching(false);
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
          <div className="w-full max-w-[80%]">
            <Select
              rightSection={
                <>
                  {
                    isFetchingSuggestions && (
                      <Loader size={24} color="teal.5" />
                    )
                  }
                </>
              }
              size="xl"
              radius={"md"}
              w={"100%"}
              m={"auto"}
              placeholder="Example: Mumbai"
              onSearchChange={handleSearch}
              onChange={handleSelect}
              value={selectedDestination}
              data={suggestions}
              checkIconPosition="right"
              searchable
              error={!isValidDestination && selectedDestination !== "" ? "Please select a valid destination" : ""}
              required
            />
            <p className="text-lg mt-3 text-gray-500">Currently tool only support Indian Locations</p>
          </div>
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
            w={"90%"}
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
                      } else if (selectedInterests.length < 8) {  // Check if less than 8 interests are selected
                        setSelectedInterests([...selectedInterests, index]);
                      } else if (selectedInterests.length > 8) {  // Check if less than 8 interests are selected
                        setInterestError(true);
                      }
                    }}
                  >
                    {interest}
                  </Chip>
                ))
              }
            </Group>hange
          </Chip.Group>
          {
            interestError && (
              <Text c="red.5" size="md" mt={4}>
                Please select at most 8 interests
              </Text>
            )
          }
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
          <Button disabled={interestError} loading={isFetching} loaderProps={{ type: 'dots' }} onClick={handleSubmit} color="teal.5" size="md">
            Submit
          </Button>
        ) : (
          <Button
            size="md"
            variant="filled"
            radius={"md"}
            color="teal.5"
            onClick={() => setActive((prev) => prev + 1)}
            disabled={active === 1 && !isValidDestination}
          >
            Next
          </Button>
        )}
      </div>
    </form>
  )

  const [showDayIndex, setShowDayIndex] = useState(0);
  const [timelineActiveIndex, setTimelineActiveIndex] = useState(0)
  // itineraries contains the list of itineraries of each day array of array(days) of places

  const renderResults = () => (
    <div className="flex flex-col lg:flex-row h-screen w-full">
      <div className="w-full lg:w-1/2 overflow-y-auto">
        <div className="flex flex-col items-center gap-4 lg:gap-8 mb-4 lg:mb-8 w-full mx-auto p-4">
          <label className="font-semibold text-4xl text-center py-4">
            Here are some itineraries for you
          </label>
          <div className="max-w-[400px] w-full">
            <SegmentedControl
              value={showDayIndex}
              withItemsBorders={false}
              onChange={setShowDayIndex}
              fullWidth
              size="md"
              radius={"xl"}
              data={itineraries.map((_, index) => ({
                value: index,
                label: `Day ${index + 1}`
              }))}
            />
          </div>
          {itineraries.map((day, dayIndex) => (
            <div
              key={dayIndex}
              className={`flex flex-col gap-8 mb-8 max-w-[400px] w-full ${showDayIndex !== dayIndex ? 'hidden' : ''
                }`}
            >
              <Timeline color="teal.5" active={timelineActiveIndex} bulletSize={32} lineWidth={4}>
                {day.map((activity, activityIndex) => (
                  <Timeline.Item
                    key={activityIndex}
                    lineVariant="dashed"
                    bullet={
                      activity.break ? (
                        <UtensilsIcon
                          size={20}
                          className="cursor-pointer"
                        />
                      ) : (
                        <MapPinIcon
                          size={20}
                          className="cursor-pointer"
                          onClick={() => { setTimelineActiveIndex(activityIndex) }}
                        />
                      )
                    }
                    title={
                      activity.place ? (
                        <Text fz={24} fw={"bold"} tt={"capitalize"} className="cursor-pointer" size="xl" my={10}
                          onClick={() => { setTimelineActiveIndex(activityIndex) }}
                        >
                          {activity.place.name}
                        </Text>
                      ) : (
                        <Text c="teal.5" fz={"bold"} tt={"capitalize"} size="md" my={16}>
                          {activity.break}
                        </Text>
                      )
                    }
                  >
                    {activity.place && (
                      <>
                        <div className="flex items-center flex-grow gap-4">
                          {activity.category?.map((category, index) => (
                            <Badge key={index} variant="default" size="lg" radius="xl" className="mr-2">
                              {category}
                            </Badge>
                          ))}
                        </div>
                        <div className="flex items-center gap-4">
                          <Text c={"dimmed"} size="md" mt={4}>
                            {activity.place.average_time_spent} hours
                          </Text>
                          <Rating fractions={10} readOnly defaultValue={parseFloat(activity.place.rating)} size="md" />
                        </div>
                      </>
                    )}
                  </Timeline.Item>
                ))}
              </Timeline>
            </div>
          ))}
        </div>
      </div>

      <div className="w-full lg:w-1/2 h-[50vh] lg:h-screen">
        <div id="map" className="h-full">
          <ItineraryMap showDay={showDayIndex} timelineActiveIndex={timelineActiveIndex} lat={latitude} long={longitude} data={itineraries} />
        </div>
      </div>
    </div >
  );


  return (
    <MantineProvider>
      <div className="flex flex-col h-screen">
        {showResults ? (
          <>
            <div className="flex flex-grow items-center justify-center">
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
