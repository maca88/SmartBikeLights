import React from 'react';
import { action } from 'mobx';
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';
import { observer } from 'mobx-react-lite';
import { headlightList, taillightList, getDeviceLights } from '../constants';
import { getDevice, deviceList } from '../widgetConstants';
import AppSelect from '../inputs/AppSelect';
import Configuration from '../models/Configuration';
import LightConfiguration from './LightConfiguration';
import ConfigurationResult from './ConfigurationResult';
import IndividualLightNetwork from './IndividualLightNetwork';
import ParseConfiguration from './ParseConfiguration';

const useStyles = makeStyles((theme) => ({
  cardHeader: {
    backgroundColor:
      theme.palette.mode === 'light'
        ? theme.palette.grey[200]
        : theme.palette.grey[700],
  },
  card: {
    marginTop: theme.spacing(2)
  }
}));

export default observer(() => {
  const classes = useStyles();
  const [configuration, setConfiguration] = React.useState(new Configuration());
  const [device, setDevice] = React.useState(null);
  const setNewDevice = action((device) => {
    setDevice(getDevice(device));
    configuration.setDevice(device);
  });
  const setNewConfiguration = action((newConfiguration) => {
    setDevice(getDevice(newConfiguration.device));
    setConfiguration(newConfiguration);
  });

  return (
    <React.Fragment>
      <ParseConfiguration setConfiguration={setNewConfiguration} deviceList={deviceList} />
      <Grid container spacing={2} justify="center">
        <Grid item xs={12} sm={12}>
          <AppSelect required items={deviceList} label="Garmin device" setter={setNewDevice} value={configuration.device} />
        </Grid>
      </Grid>
      <IndividualLightNetwork device={device} configuration={configuration} />
      { device ? (
        <React.Fragment>
          <LightConfiguration
            className={classes.card}
            headerClassName={classes.cardHeader}
            useIndividualNetwork={configuration.useIndividualNetwork}
            device={device}
            lightType="Headlight"
            lightList={getDeviceLights(device, headlightList, configuration.useIndividualNetwork)}
            light={configuration.headlight}
            setLight={configuration.setHeadlight}
            setLightModes={configuration.setHeadlightModes}
            lightPanel={configuration.headlightPanel}
            setLightPanel={configuration.setHeadlightPanel}
            lightSettings={configuration.headlightSettings}
            setLightSettings={configuration.setHeadlightSettings}
            deviceNumber={configuration.headlightDeviceNumber}
            setDeviceNumber={configuration.setHeadlightDeviceNumber}
          />
          <LightConfiguration
            className={classes.card}
            headerClassName={classes.cardHeader}
            useIndividualNetwork={configuration.useIndividualNetwork}
            device={device}
            lightType="Taillight"
            lightList={getDeviceLights(device, taillightList, configuration.useIndividualNetwork)}
            light={configuration.taillight}
            setLight={configuration.setTaillight}
            setLightModes={configuration.setTaillightModes}
            lightPanel={configuration.taillightPanel}
            setLightPanel={configuration.setTaillightPanel}
            lightSettings={configuration.taillightSettings}
            setLightSettings={configuration.setTaillightSettings}
            deviceNumber={configuration.taillightDeviceNumber}
            setDeviceNumber={configuration.setTaillightDeviceNumber}
          />
          <ConfigurationResult 
            className={classes.card}
            headerClassName={classes.cardHeader}
            configuration={configuration}
            deviceList={deviceList}
          />
        </React.Fragment>
      ) : null }
    </React.Fragment>
  );
});
