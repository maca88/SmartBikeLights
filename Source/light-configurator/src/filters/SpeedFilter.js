import React, { useContext, useEffect } from 'react';
import Grid from '@material-ui/core/Grid';
import AppSelect from '../inputs/AppSelect';
import AppTextInput from '../inputs/AppTextInput';
import { operatorList, speedUnitList } from '../constants';
import { observer } from 'mobx-react-lite';
import { AppContext } from '../AppContext';

export default observer(({ filter }) => {
  const { units } = useContext(AppContext);
  const [speed, setSpeed] = React.useState(null);
  const setFilterValue = (speed) => {
    let mps = null;
    if (speed !== '' && !Number.isNaN(speed)) {
      mps = units === 1 /* Statute */
        ? speed * 0.44704
        : speed * 0.27777777777778;
    }

    filter.setValue(mps === null ? null : Math.round(mps * 100000) / 100000);
  };

  useEffect(() => {
    let newSpeed = null;
    if (filter.value !== null && !Number.isNaN(filter.value)) {
      newSpeed = units === 0 /* Metric */
        ? filter.value * 3.6
        : filter.value * 2.236934;
    }

    setSpeed(newSpeed === null ? null : Math.round(newSpeed * 100) / 100);
  }, [units, filter.value]);

  return (
    <Grid container spacing={3}>
      <Grid item xs={12} sm={4}>
        <AppSelect required items={operatorList} label="Operator" setter={filter.setOperator} value={filter.operator} /> 
      </Grid>
      <Grid item xs={12} sm={5}>
        <AppTextInput required label="Speed" type="number" setter={setFilterValue} value={speed} />
      </Grid>
      <Grid item xs={12} sm={3}>
        <AppSelect items={speedUnitList} label="Units" value={units} />
      </Grid>
    </Grid>
  );
});