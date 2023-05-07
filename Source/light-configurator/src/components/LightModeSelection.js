import React from 'react';
import Grid from '@mui/material/Grid';
import { observer } from 'mobx-react-lite';
import { controlModeList } from '../constants';
import AppSelect from '../inputs/AppSelect';

const operators = [
  { id: '=', name: 'Equal' },
  { id: '!', name: 'Not Equal' }
];

export default observer(({ controlMode, setControlMode, lightMode, setLightMode, lightModes, setOperator, operator }) => {

  const hasOperator = setOperator != null;

  return (
    <Grid container spacing={3}>
      {
        hasOperator ?
        <Grid item xs={12} sm={hasOperator ? 4 : 6}>
          <AppSelect required={controlMode != null} items={operators} label="Operator" setter={setOperator} value={operator} />
        </Grid>
        : null
      }
      <Grid item xs={12} sm={hasOperator ? 4 : 6}>
        <AppSelect items={controlModeList} label="Control modes" setter={setControlMode} value={controlMode} />
      </Grid>
      {
        controlMode === 2 /* MANUAL */
        ?
        <Grid item xs={12} sm={hasOperator ? 4 : 6}>
          <AppSelect required items={lightModes} label="Light mode" setter={setLightMode} value={lightMode} />
        </Grid>
        : null
      }
    </Grid>
  );
});
