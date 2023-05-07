import React from 'react';
import Grid from '@mui/material/Grid';
import { observer } from 'mobx-react-lite';
import AppSelect from '../inputs/AppSelect';
import LightsPaper from '../components/LightsPaper';
import LightIconTapBehavior from '../components/LightIconTapBehavior';
import { toneList } from '../constants';

export default observer(({ configuration, action }) => {

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
          <LightIconTapBehavior lightIconTapBehavior={action.headlightTapBehavior} lightModes={headlight.modes} />
        )}
        getTaillightNode={(taillight) => (
          <LightIconTapBehavior lightIconTapBehavior={action.taillightTapBehavior} lightModes={taillight.modes} />
        )}
      />
    </div>
  );
});
