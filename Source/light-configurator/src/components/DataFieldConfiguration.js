import React from 'react';
import { action } from 'mobx';
import Grid from '@material-ui/core/Grid';
import { observer } from 'mobx-react-lite';
import { timeFormatList, unitList } from '../constants';
import AppSelect from '../inputs/AppSelect';
import Configuration from '../models/Configuration';
import DeviceConfiguration from './DeviceConfiguration';
import ParseConfiguration from './ParseConfiguration';
import { AppContext, getContextValue } from '../AppContext';
import { getDevice, deviceList } from '../dataFieldConstants';

const getDefaultState = () => {
  const configuration = new Configuration();
  return {
    configuration: configuration,
    device: null,
    context: getContextValue(configuration),
  };
};

export default observer(() => {
  const [state, setState] = React.useState(getDefaultState());
  const setUnits = (value) => {
    state.configuration.setUnits(value);
    setState({ ...state, context: getContextValue(state.configuration) });
  };
  const setTimeFormat = (value) => {
    state.configuration.setTimeFormat(value);
    setState({ ...state, context: getContextValue(state.configuration) });
  };
  const setDevice = action((device) => {
    state.configuration.setDevice(device);
    setState({ ...state, device: getDevice(device) });
  });
  const setNewConfiguration = action((newConfiguration) => {
    setState({
      configuration: newConfiguration,
      device: getDevice(newConfiguration.device),
      context: getContextValue(newConfiguration)
    });
  });

  return (
    <AppContext.Provider value={state.context}>
      <ParseConfiguration setConfiguration={setNewConfiguration} deviceList={deviceList} />
      <Grid container spacing={2} justify="center">
        <Grid item xs={12} sm={4}>
          <AppSelect required items={deviceList} label="Garmin device" setter={setDevice} value={state.configuration.device} />
        </Grid>
        <Grid item xs={6} sm={4}>
          <AppSelect required items={unitList} label="Units" setter={setUnits} value={state.configuration.units} />
        </Grid>
        <Grid item xs={6} sm={4}>
          <AppSelect required items={timeFormatList} label="Time format" setter={setTimeFormat} value={state.configuration.timeFormat} />
        </Grid>
      </Grid>
      { state.device ? <DeviceConfiguration configuration={state.configuration} device={state.device} deviceList={deviceList} /> : null }
    </AppContext.Provider>
  );
});
