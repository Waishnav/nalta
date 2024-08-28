import { MantineProvider, Stepper } from "@mantine/core";
import React, { useState } from "react";

const CreateItenariesForm = ({ destinations }) => {
  const [active, setActive] = useState(1);

  return (
    <MantineProvider>
      <Stepper active={active} onStepClick={setActive}>
        <Stepper.Step label="Step 1" description="Create an account" />
        <Stepper.Step label="Step 2" description="Verify email" />
        <Stepper.Step label="Step 3" description="Get full access" />
      </Stepper>
    </MantineProvider>
  )
}

export default CreateItenariesForm
