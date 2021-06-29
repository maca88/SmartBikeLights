import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Typography from '@material-ui/core/Typography';
import Grid from '@material-ui/core/Grid';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import CardHeader from '@material-ui/core/CardHeader';
import { observer } from 'mobx-react-lite'
import FilterGroups from './FilterGroups';
import LightConfiguration from './LightConfiguration';
import ConfigurationResult from './ConfigurationResult';
import ElementWithHelp from './ElementWithHelp';
import IndividualLightNetwork from './IndividualLightNetwork';
import { headlightList, taillightList, getDeviceLights } from '../constants';

const useStyles = makeStyles((theme) => ({
  copyButton: {
    marginTop: theme.spacing(4),
  },
  cardHeader: {
    backgroundColor:
      theme.palette.mode === 'light'
        ? theme.palette.grey[200]
        : theme.palette.grey[700],
  },
  card: {
    marginTop: theme.spacing(2)
  },
  filterGroups: {
    marginBottom: theme.spacing(1),
  }
}));

export default observer(({ configuration, device, deviceList }) => {
  const classes = useStyles();

  return (
      <React.Fragment>
        <IndividualLightNetwork device={device} configuration={configuration} />
        <Card className={classes.card}>
          <CardHeader
            title="Global Filters"
            titleTypographyProps={{ align: 'center' }}
            className={classes.cardHeader}
          />
          <CardContent>
            <Grid item xs={12} sm={12}>
              <ElementWithHelp
                rootClass={classes.filterGroups}
                element={<Typography variant="h5" color="textPrimary">Filter groups</Typography>}
                help={
                  <Typography color="textPrimary">
                    Global filter groups contains a group of filters, which are used by the Smart mode to determine when the filter groups defined on the
                    lights will be used. When all filters conditions inside a filter group is met, then the light mode will be determined by the group filters
                    defined on the light, otherwise the "Default mode" on the light will be used. Global filter are useful when we have a condition that 
                    applies to all lights. For example, in case we don't want the lights to be turned on when the timer is not recording,
                    we can add a global filter group with a "Timer state" filter with condition "Greater than Not recording" and set the "Default mode"
                    to "Off" on the lights.
                  </Typography>
                }
              />
            </Grid>
            <FilterGroups filterGroups={configuration.globalFilterGroups} device={device} />
          </CardContent>
        </Card>

        <LightConfiguration
          className={classes.card}
          headerClassName={classes.cardHeader}
          globalFilterGroups={configuration.globalFilterGroups}
          useIndividualNetwork={configuration.useIndividualNetwork}
          device={device}
          lightType="Headlight"
          lightList={getDeviceLights(device, headlightList, configuration.useIndividualNetwork)}
          lightFilterGroups={configuration.headlightFilterGroups}
          light={configuration.headlight}
          setLight={configuration.setHeadlight}
          setLightModes={configuration.setHeadlightModes}
          setDefaultMode={configuration.setHeadlightDefaultMode}
          defaultMode={configuration.headlightDefaultMode}
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
          globalFilterGroups={configuration.globalFilterGroups}
          useIndividualNetwork={configuration.useIndividualNetwork}
          device={device}
          lightType="Taillight"
          lightList={getDeviceLights(device, taillightList, configuration.useIndividualNetwork)}
          light={configuration.taillight}
          setLight={configuration.setTaillight}
          setLightModes={configuration.setTaillightModes}
          lightFilterGroups={configuration.taillightFilterGroups}
          setDefaultMode={configuration.setTaillightDefaultMode}
          defaultMode={configuration.taillightDefaultMode}
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
    );
});
