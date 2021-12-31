import React from 'react';
import Grid from '@mui/material/Grid';
import { observer } from 'mobx-react-lite';
import Typography from '@mui/material/Typography';
import ElementWithHelp from './ElementWithHelp';
import AppCheckbox from '../inputs/AppCheckbox';

export default observer(({ device, configuration, }) => {
  return (
    <React.Fragment>
      {
        device?.highMemory ?
          <Grid container spacing={2} justifyContent="center">
            <Grid item xs={12} sm={12}>
              <ElementWithHelp
                element={
                  <AppCheckbox label="Use Individual Light Network" value={configuration.useIndividualNetwork} setter={configuration.setUseIndividualNetwork} />
                }
                help={
                  <React.Fragment>
                    <Typography gutterBottom>
                      Individal Light Network is an alternative light network implementation for connecting and controlling ANT+ lights. In comparison
                      to the Garmin built-in light network, this network does not form a light network when two lights are connected, but instead it
                      establish a separate connection for every light. This mode needs to be used for lights that have issues with the built-in
                      light network (See.Sense and Cycliq lights).
                </Typography>
                    <Typography gutterBottom>
                      <strong>NOTE: Lights in Garmin Sensors menu need to be disabled or removed in order to use this feature!</strong>
                    </Typography>
                    <Typography>
                      Known limitations:
                </Typography>
                    <ul>
                      <li><Typography>It requires to manually set the device numbers for the lights</Typography></li>
                      <li><Typography>It will not turn off the lights when the device goes to sleep</Typography></li>
                      <li><Typography>It uses one ANT channel per light</Typography></li>
                    </ul>
                  </React.Fragment>
                }
              />
            </Grid>
          </Grid>
          : null
      }
    </React.Fragment>
  );
});
