import React, { useEffect } from 'react';
import Grid from '@mui/material/Grid';
import { observer } from 'mobx-react-lite';
import { controlModeList, manualModeBehaviorList } from '../constants';
import AppSelect from '../inputs/AppSelect';

export default observer(({ lightIconTapBehavior, lightModes }) => {
  useEffect(() => {
    if (lightIconTapBehavior.lightModes) {
      lightIconTapBehavior.setLightModes(lightIconTapBehavior.lightModes.filter(m => lightModes.find(lm => lm.id === m) !== undefined));
    }
  }, [lightIconTapBehavior, lightModes]);

  return (
    <div>
      <Grid container spacing={3}>
        <Grid item xs={6} sm={4}>
          <AppSelect items={controlModeList} label="Control modes" setter={lightIconTapBehavior.setControlModes} value={lightIconTapBehavior.controlModes} multiple={true} />
        </Grid>
        {
          lightIconTapBehavior.containsManualMode()
          ?
          <Grid item xs={6} sm={4}>
            <AppSelect required items={manualModeBehaviorList} label="Manual mode behavior" setter={lightIconTapBehavior.setManualModeBehavior} value={lightIconTapBehavior.manualModeBehavior} />
          </Grid>
          : null
        }
        {
          lightIconTapBehavior.containsManualMode() && lightIconTapBehavior.manualModeBehavior === 1
          ?
          <Grid item xs={12} sm={4}>
            <AppSelect required items={lightModes} label="Light modes" setter={lightIconTapBehavior.setLightModes} value={lightIconTapBehavior.lightModes} multiple={true} />
          </Grid>
          : null
        }
      </Grid>
    </div>
  );
});
