import React from 'react';
import { action } from 'mobx';
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';
import { observer } from 'mobx-react-lite';
import { headlightList, taillightList } from '../constants';
import { getDevice, deviceList } from '../widgetConstants';
import AppSelect from '../inputs/AppSelect';
import Configuration from '../models/Configuration';
import LightConfiguration from './LightConfiguration';
import ConfigurationResult from './ConfigurationResult';

const configuration = new Configuration();
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
  const [device, setDevice] = React.useState(getDevice(configuration.device));
  const setGarminDevice = action((device) => {
    setDevice(getDevice(device));
    configuration.setDevice(device);
  });

  return (
    <React.Fragment>
      <Grid container spacing={2} justify="center">
        <Grid item xs={12} sm={12}>
          <AppSelect required items={deviceList} label="Garmin device" setter={setGarminDevice} value={configuration.device} />
        </Grid>
      </Grid>
      { device ? (
        <React.Fragment>
          <LightConfiguration
            className={classes.card}
            headerClassName={classes.cardHeader}
            device={device}
            lightType="Headlight"
            lightList={headlightList}
            light={configuration.headlight}
            setLight={configuration.setHeadlight}
            setLightModes={configuration.setHeadlightModes}
            lightPanel={configuration.headlightPanel}
            setLightPanel={configuration.setHeadlightPanel}
            lightSettings={configuration.headlightSettings}
            setLightSettings={configuration.setHeadlightSettings}
          />
          <LightConfiguration
            className={classes.card}
            headerClassName={classes.cardHeader}
            device={device}
            lightType="Taillight"
            lightList={taillightList}
            light={configuration.taillight}
            setLight={configuration.setTaillight}
            setLightModes={configuration.setTaillightModes}
            lightPanel={configuration.taillightPanel}
            setLightPanel={configuration.setTaillightPanel}
            lightSettings={configuration.taillightSettings}
            setLightSettings={configuration.setTaillightSettings}
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
