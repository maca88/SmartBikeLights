import React from 'react';
import Grid from '@mui/material/Grid';
import AppSelect from '../inputs/AppSelect';
import AppTextInput from '../inputs/AppTextInput';
import AppTimePicker from '../inputs/AppTimePicker';
import { observer } from "mobx-react-lite"
import { timespanTypeList } from "../constants";
import addSeconds from "date-fns/addSeconds";
import startOfToday from "date-fns/startOfToday";
import { setSeconds, differenceInSeconds } from 'date-fns'
import { Typography } from '@mui/material';

export default observer(({ filter }) => {
  const getInitValue = (type, value) => {
    if (value === null) {
      return null;
    }

    return type === '0' /* Time */
      ? addSeconds(startOfToday(), value)
      : value / 60;
  }

  const getFilterValue = (type, value) => {
    if (value === null) {
      return null;
    }

    return type === '0' /* Time */
      ? differenceInSeconds(value, startOfToday())
      : value * 60;
  }

  const [state, setState] = React.useState({ 
    fromValue: getInitValue(filter.fromType, filter.fromValue),
    toValue: getInitValue(filter.toType, filter.toValue)
  });

  const setFromValue = (value) => {
    value = filter.fromType === '0' /* Time */ ? setSeconds(value, 0) : value;
    filter.setFromValue(getFilterValue(filter.fromType, value));
    setState({ fromValue: value, toValue: state.toValue });
  };
  const setToValue = (value) => {
    value = filter.toType === '0' /* Time */ ? setSeconds(value, 0) : value;
    filter.setToValue(getFilterValue(filter.toType, value));
    setState({ fromValue: state.fromValue, toValue: value });
  };

  return (
    <Grid container spacing={3}>
      <Grid item xs={12} sm={12}>
        <Typography>
          NOTE: When using Sunset and Sunrise, the filter will start working only when a GPS position will be acquired, as it is required
          to calculate the sunrise and sunset time.
        </Typography>
      </Grid>
      <Grid item xs={12} sm={6}>
        <AppSelect required items={timespanTypeList} label="From" setter={filter.setFromType} value={filter.fromType} />
      </Grid>
      <Grid item xs={12} sm={6}>
        {
          !filter.fromType ? null
          : filter.fromType === '0' ? <AppTimePicker setter={setFromValue} value={state.fromValue} />
          : <AppTextInput required label="Offset in minutes" type="number" setter={setFromValue} value={state.fromValue} />
        }
      </Grid>
      <Grid item xs={12} sm={6}>
        <AppSelect required items={timespanTypeList} label="To" setter={filter.setToType} value={filter.toType} />
      </Grid>
      <Grid item xs={12} sm={6}>
        {
          !filter.toType ? null
          : filter.toType === '0' ? <AppTimePicker setter={setToValue} value={state.toValue} />
          : <AppTextInput required label="Offset in minutes" type="number" setter={setToValue} value={state.toValue} />
        }
      </Grid>
    </Grid>
  );
});