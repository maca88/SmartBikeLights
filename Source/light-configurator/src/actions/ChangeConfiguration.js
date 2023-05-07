import React from 'react';
import Grid from '@mui/material/Grid';
import { observer } from 'mobx-react-lite';
import AppSelect from '../inputs/AppSelect';
import { configurationList, toneList } from '../constants';

export default observer(({ action }) => {

  return (
    <Grid container spacing={3} sx={{ marginBottom: 2 }}>
      <Grid item xs={12} sm={6}>
        <AppSelect required items={configurationList} label="Configuration" setter={action.setConfigurationId} value={action.configurationId} />
      </Grid>
      <Grid item xs={12} sm={6}>
        <AppSelect items={toneList} label="Press tone" setter={action.setToneId} value={action.toneId} />
      </Grid>
    </Grid>
  );
});
