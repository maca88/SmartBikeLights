import React from 'react';
import Grid from '@mui/material/Grid';
import { observer } from 'mobx-react-lite';
import AppSelect from '../inputs/AppSelect';
import { toneList } from '../constants';
import LightsPaper from '../components/LightsPaper';
import LightModeSelection from '../components/LightModeSelection';

export default observer(({ configuration, action }) => {

  const headlightMode = action.headlightMode;
  const taillightMode = action.taillightMode;

  return (
    <div>
      <Grid container spacing={3} sx={{ marginBottom: 2 }}>
        <Grid item xs={12} sm={6}>
          <AppSelect items={toneList} label="Press tone" setter={action.setToneId} value={action.toneId} />
        </Grid>
      </Grid>
      <LightsPaper
        configuration={configuration}
        getHeadlightNode={(headlight) => (
          <LightModeSelection
            controlMode={headlightMode.controlMode} setControlMode={headlightMode.setControlMode}
            lightMode={headlightMode.lightMode} setLightMode={headlightMode.setLightMode} lightModes={headlight.modes} />
        )}
        getTaillightNode={(taillight) => (
          <LightModeSelection
            controlMode={taillightMode.controlMode} setControlMode={taillightMode.setControlMode}
            lightMode={taillightMode.lightMode} setLightMode={taillightMode.setLightMode} lightModes={taillight.modes} />
        )}
      />
    </div>
  );
});
