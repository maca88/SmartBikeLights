import React from 'react';
import Button from '@material-ui/core/Button';
import Grid from '@material-ui/core/Grid';
import Alert from '@material-ui/core/Alert';
import { makeStyles } from '@material-ui/core/styles';
import { observer } from 'mobx-react-lite';
import { timeFormatList, unitList } from '../constants';
import { deviceList } from '../dataFieldConstants';
import AppSelect from '../inputs/AppSelect';
import AppTextInput from '../inputs/AppTextInput';
import Configuration from '../models/Configuration';
import DeviceConfiguration from './DeviceConfiguration';
import { AppContext, getContextValue } from '../AppContext';

const useStyles = makeStyles((theme) => ({
  parseButtonCell: {
    marginBottom: 'auto',
    marginTop: 'auto'
  },
  parseButton: {
    width: '100%'
  }
}));

export default observer(() => {
  const classes = useStyles();
  let configuration = new Configuration();
  const [state, setState] = React.useState({
    configuration: configuration,
    existingConfigurationValue: null,
    context: getContextValue(configuration),
    parseError: false
  });
  const setUnits = (value) => {
    state.configuration.setUnits(value);
    setState({ ...state, context: getContextValue(state.configuration) });
  };
  const setTimeFormat = (value) => {
    state.configuration.setTimeFormat(value);
    setState({ ...state, context: getContextValue(state.configuration) });
  };
  const setExistingConfigurationValue = (value) => {
    setState({ ...state, existingConfigurationValue: value });
  };
  const parse = (value) => {
    try {
      configuration = Configuration.parse(value, deviceList);
      if (!configuration) {
        setState({
          ...state,
          existingConfigurationValue: null,
          parseError: true
        });
        return;
      }

      setState({
        configuration: configuration,
        existingConfigurationValue: null,
        context: getContextValue(configuration),
        parseError: false
      });
    }
    catch (e) {
      setState({
        ...state,
        existingConfigurationValue: null,
        parseError: true
      });
    }
  };

  return (
    <AppContext.Provider value={state.context}>
      <Grid container spacing={2} justify="center">
        <Grid item xs={8} sm={10}>
          <AppTextInput label="Existing configuration" value={state.existingConfigurationValue} setter={setExistingConfigurationValue} />
        </Grid>
        <Grid item xs={4} sm={2} className={classes.parseButtonCell}>
          <Button className={classes.parseButton} variant="contained" onClick={() => {parse(state.existingConfigurationValue, deviceList)}}>Parse</Button>
        </Grid>
        { state.parseError ?
          <Grid item xs={12} sm={12}>
            <Alert severity="error">Invalid configuration.</Alert>
          </Grid>
          : null
        }
        <Grid item xs={12} sm={4}>
          <AppSelect required items={deviceList} label="Garmin device" setter={state.configuration.setDevice} value={state.configuration.device} />
        </Grid>
        <Grid item xs={6} sm={4}>
          <AppSelect required items={unitList} label="Units" setter={setUnits} value={state.configuration.units} />
        </Grid>
        <Grid item xs={6} sm={4}>
          <AppSelect required items={timeFormatList} label="Time format" setter={setTimeFormat} value={state.configuration.timeFormat} />
        </Grid>
      </Grid>
      { state.configuration.device ? <DeviceConfiguration configuration={state.configuration} /> : null }
    </AppContext.Provider>
  );
});
