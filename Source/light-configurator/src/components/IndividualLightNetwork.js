import React from 'react';
import Grid from '@material-ui/core/Grid';
import { observer } from 'mobx-react-lite';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Typography from '@material-ui/core/Typography';
import Checkbox from '@material-ui/core/Checkbox';
import ElementWithHelp from './ElementWithHelp';

export default observer(({ device, configuration, }) => {
  return (
    <React.Fragment>
      {
        device?.highMemory ?
          <Grid container spacing={2} justify="center">
            <Grid item xs={12} sm={12}>
              <ElementWithHelp
                element={
                  <FormControlLabel
                    control={
                      <Checkbox checked={configuration.useIndividualNetwork}
                        onChange={(e) => configuration.setUseIndividualNetwork(e.target.checked)}
                        name="useIndividualNetwork" />
                    }
                    label="Use Individual Light Network"
                  />
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
