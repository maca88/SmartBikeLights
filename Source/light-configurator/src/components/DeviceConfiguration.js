import React, { useEffect } from 'react';
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
import { headlightList, taillightList } from '../constants';
import { getDevice, deviceList } from '../dataFieldConstants';

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
  }
}));

export default observer(({ configuration }) => {
  const classes = useStyles();
  const [device, setDevice] = React.useState(getDevice(configuration.device));
  useEffect(
    () => {
      setDevice(getDevice(configuration.device));
    },
    [configuration.device]
  );

  return (
      <React.Fragment>
        <Card className={classes.card}>
          <CardHeader
            title="Global Filters"
            titleTypographyProps={{ align: 'center' }}
            className={classes.cardHeader}
          />
          <CardContent>
            <Typography color="textPrimary" gutterBottom>
            Global filters are the first filters that are checked when the lights are in Smart mode and in case none of the defined filters evaluates to be true, 
            the head/tail lights filters won't be evaluated. In other words, with global filters we can define filters that we want to apply for both tail 
            and head lights (e.g. turn them on after sunset). In case you have only one light or don't have any common filter for both lights, just leave it 
            empty and head/taillight filters will be evaluated. In order to define a filter that requires multiple conditions to be true, we have so called filter 
            groups, that consist of one or more filters that must be true so that the whole filter group is evaluated to true. In case you need that any of the 
            defined filters turns on the lights, create a filter group for each filter. In short, the Smart mode logic uses AND operator for filters inside a 
            filter group and OR operator for filter groups. For each filter group a name can be set that will be displayed on your Garmin device (only when enough space is available) when evaluated to true, so that it is easier to understand which filter group triggered the lights to be turned on. When having 
            multiple filter groups, the name of the first one to be evaluated as true will be used.
            </Typography>
            <Grid className={classes.card} item xs={12} sm={12}>
              <Typography variant="h5" color="textPrimary">
                  Filter groups
              </Typography>
            </Grid>
            <FilterGroups filterGroups={configuration.globalFilterGroups} device={device} />
          </CardContent>
        </Card>
        
        <LightConfiguration
          className={classes.card}
          headerClassName={classes.cardHeader}
          globalFilterGroups={configuration.globalFilterGroups}
          device={device}
          lightType="Headlight"
          lightList={headlightList}
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
        />
        <LightConfiguration
          className={classes.card}
          headerClassName={classes.cardHeader}
          globalFilterGroups={configuration.globalFilterGroups}
          device={device}
          lightType="Taillight"
          lightList={taillightList}
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
