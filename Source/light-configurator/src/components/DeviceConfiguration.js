import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import Grid from '@material-ui/core/Grid';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import CardHeader from '@material-ui/core/CardHeader';
import Alert from '@material-ui/core/Alert';
import { observer } from 'mobx-react-lite'
import FilterGroups from './FilterGroups';
import LightConfiguration from './LightConfiguration';
import AppTextInput from '../inputs/AppTextInput';
import { headlightList, taillightList } from '../constants';

const useStyles = makeStyles((theme) => ({
  mainContent: {
    backgroundColor: theme.palette.background.paper,
    padding: theme.spacing(8, 0, 6),
  },
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
            <FilterGroups filterGroups={configuration.globalFilterGroups} device={configuration.device} />
          </CardContent>
        </Card>
        
        <LightConfiguration
          className={classes.card}
          headerClassName={classes.cardHeader}
          device={configuration.device}
          globalFilterGroups={configuration.globalFilterGroups}
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
        />
        <LightConfiguration
          className={classes.card}
          headerClassName={classes.cardHeader}
          device={configuration.device}
          globalFilterGroups={configuration.globalFilterGroups}
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
        />

        <Card className={classes.card}>
          <CardHeader
            title="Lights Configuration"
            titleTypographyProps={{ align: 'center' }}
            className={classes.cardHeader}
          />
          <CardContent>
            <Typography color="textPrimary" gutterBottom>
            When the lights are configured copy the below value and paste it in the Smart Light Bike application setting 'Lights Configuration' by using 
            Garmin Connect Mobile. Do not use Garmin Express as it is limited to 256 characters.
            </Typography>
            {configuration.isValid() ?
            <React.Fragment>
              <Grid item xs={12} sm={12}>
                <AppTextInput value={configuration.getConfigurationValue()} />
              </Grid>
              <Grid item className={classes.copyButton} xs={12} sm={12}>
                <Button variant="contained" onClick={() => {navigator.clipboard.writeText(configuration.getConfigurationValue())}}>Copy to clipboard</Button>
              </Grid>
            </React.Fragment>
            :
            <Grid item xs={12} sm={12}>
              <Alert severity="error">Please fill the missing fields.</Alert>
            </Grid>
            }
          </CardContent>
        </Card>
      </React.Fragment>
    );
});
