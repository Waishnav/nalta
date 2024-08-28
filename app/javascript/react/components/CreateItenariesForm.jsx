import { Button, Chip, Group, Input, MantineProvider, Progress, Select, Slider } from "@mantine/core";
import '@mantine/dates/styles.css';
import React, { useState } from "react";

const CreateItenariesForm = ({ authenticity_token, destinations, interests }) => {
  const [active, setActive] = useState(1);
  const [selectedInterests, setSelectedInterests] = useState([1]);

  return (
    <MantineProvider>
      <div className="flex flex-col h-screen">
        {/* Progress bar at the top */}
        <div className="flex justify-center mt-8">
          <Progress color="black" value={(active) * 100 / 3} w={900} />
        </div>

        {/* Centered form content */}
        <div className="flex flex-grow items-center justify-center">
          <form
            onSubmit={() => {
              setActive((prev) => prev + 1);
            }}
            action="/itineraries" method="post"
            className="flex flex-col items-center gap-8 max-w-[800px] w-full"
          >
            <input type="hidden" name="authenticity_token" value={authenticity_token} />
            {active === 1 && (
              <>
                <label htmlFor="destination" className="font-semibold text-4xl py-4">
                  Where do you want to go?
                </label>
                <Input.Wrapper>
                  <Select
                    rightSection={<></>}
                    size="xl"
                    radius={"md"}
                    w={800}
                    placeholder="Example: Mumbai"
                    data={[
                      { value: "Mumbai", label: "Mumbai" },
                    ]}
                    checkIconPosition="right"
                    searchable
                    required
                  />
                </Input.Wrapper>
              </>
            )}

            {active === 2 && (
              <>
                <label htmlFor="duration" className="font-semibold text-4xl py-4">
                  How many days of trip?
                </label>
                <Input.Wrapper>
                  <Slider
                    name="duration"
                    id="duration"
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
                </Input.Wrapper>
              </>
            )}

            {active === 3 && (
              <>
                <label htmlFor="interests" className="font-semibold text-4xl py-4">
                  Tell us what you’re interested in
                </label>
                <Input.Wrapper>
                  <Chip.Group multiple>
                    <Group justify="center" mt="md">
                      {
                        interests.map((interest, index) => (
                          <Chip
                            key={index}
                            variant="outline"
                            size="md"
                            color="teal.5"
                            value={index}
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
                </Input.Wrapper>
              </>
            )}

            {/* Navigation buttons at the bottom */}
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
        </div>
      </div>
    </MantineProvider>
  );
}

export default CreateItenariesForm;
