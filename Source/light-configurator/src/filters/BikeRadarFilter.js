import React, { useContext, useEffect } from 'react';
import Grid from '@material-ui/core/Grid';
import AppSelect from '../inputs/AppSelect';
import AppTextInput from '../inputs/AppTextInput';
import AppSlider from '../inputs/AppSlider';
import { AppContext } from '../AppContext';
import { operatorList, vehicleThreatList, distanceUnitList } from '../constants';
import { observer } from 'mobx-react-lite';

const getLabelText = (value) => {
  return vehicleThreatList[value];
};

export default observer(({ label, filter }) => {
  const { units } = useContext(AppContext);
  const [range, setRange] = React.useState(null);
  const setFilterValue = (range) => {
    let value = null;
    if (range !== '' && !Number.isNaN(range)) {
      value = units === 1 /* Statute */ ? range * 0.3048 : range;
    }

    filter.setValue(value === null ? null : Math.round(value * 100000) / 100000);
  };

  useEffect(() => {
    let newRange = null;
    if (filter.value !== null || !Number.isNaN(filter.value)) {
      newRange = units === 0 /* Metric */
        ? filter.value
        : filter.value * 3.2808;
    }

    setRange(newRange === null ? null : Math.round(newRange * 100) / 100);
  }, [units, filter.value]);
  return (
  <Grid container spacing={3}>
    <Grid item xs={12} sm={4}>
      <AppSelect items={operatorList} label="Range operator" setter={filter.setOperator} value={filter.operator} /> 
    </Grid>
    {
      filter.operator ?
        <React.Fragment>
          <Grid item xs={12} sm={5}>
            <AppTextInput required label="Vehicle range" type="number" setter={setFilterValue} value={range} />
          </Grid>
          <Grid item xs={12} sm={3}>
            <AppSelect items={distanceUnitList} label="Units" value={units} />
          </Grid>
        </React.Fragment>
      : <Grid item xs={12} sm={8}></Grid>
    }

    <Grid item xs={12} sm={4}>
      <AppSelect items={operatorList} label="Threat operator" setter={filter.setThreatOperator} value={filter.threatOperator} /> 
    </Grid>
    {
      filter.threatOperator ?
        <Grid item xs={12} sm={8}>
          <AppSlider
            label="Vehicle threat"
            setter={filter.setThreat}
            value={filter.threat}
            getLabelText={getLabelText}
            step={1}
            min={0}
            max={2}
            defaultValue={0}
          />
        </Grid>
      : <Grid item xs={12} sm={8}></Grid>
    }
  </Grid>
  );
});