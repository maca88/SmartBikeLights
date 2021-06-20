import React, { useEffect } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Typography from '@material-ui/core/Typography';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import CardHeader from '@material-ui/core/CardHeader';
import Grid from '@material-ui/core/Grid';
import { observer } from 'mobx-react-lite';
import FilterGroups from './FilterGroups';
import AppSelect from '../inputs/AppSelect';
import AppTextInput from '../inputs/AppTextInput';
import ElementWithHelp from './ElementWithHelp';
import LightPanel from './LightPanel';
import LightSettings from './LightSettings';
import LightPanelModel from '../models/LightPanel';
import LightSettingsModel from '../models/LightSettings';

const getModes = (value, lights) => {
  return value !== null ? lights.find(l => l.id === value)?.modes : null;
};

const getDefaultPanel = (value, lights) => {
  return value !== null ? lights.find(l => l.id === value)?.defaultLightPanel : null;
};

const useStyles = makeStyles((theme) => ({
  sectionTitle: {
    'margin-top': theme.spacing(3),
    'margin-bottom': theme.spacing(1),
  }
}));

export default observer(({
  className, headerClassName, device, useIndividualNetwork, globalFilterGroups, lightType, lightList, lightFilterGroups, setLight, light,
  setLightModes, setDefaultMode, defaultMode, lightPanel, setLightPanel, lightSettings, setLightSettings, deviceNumber, setDeviceNumber }) => {
  const classes = useStyles();
  const [modes, setModes] = React.useState(getModes(light, lightList));
  const setValue = (value) => {
    setLight(value);
    setLightModes(value !== null ? lightList.find(l => l.id === value).lightModes : null);
  };

  var hasFilters = !!setDefaultMode;

  useEffect(() => {
    setModes(getModes(light, lightList));
    if (light == null) {
      setLightPanel(null);
    } else if (lightPanel == null) {
      setLightPanel(new LightPanelModel(getDefaultPanel(light, lightList)));
    }
  }, [light, lightList, setLightPanel, lightPanel]);

  useEffect(() => {
    if (light == null) {
      setLightSettings(null);
    } else if (lightSettings == null) {
      setLightSettings(new LightSettingsModel(getDefaultPanel(light, lightList)));
    }
  }, [light, lightList, lightSettings, setLightSettings]);

  return (
    <Card className={className}>
      <CardHeader
        title={lightType + ' Configuration'}
        titleTypographyProps={{ align: 'center' }}
        className={headerClassName}
      />
      <CardContent>
        <Grid container spacing={3} justify="center">
          <Grid item xs={12} sm={4}>
            <AppSelect items={lightList} label={lightType} setter={setValue} value={light} />
          </Grid>
          {
            modes && hasFilters
            ?
            <Grid item xs={12} sm={4}>
              <AppSelect
                  required={globalFilterGroups.length || lightFilterGroups.length ? true : false}
                  items={modes}
                  label="Default mode"
                  setter={setDefaultMode}
                  value={defaultMode} />
            </Grid>
            : null
          }
          {
            useIndividualNetwork && light && device?.highMemory
            ?
            <Grid item xs={12} sm={4}>
              <AppTextInput required label="Device number" type="number"
                setter={setDeviceNumber} 
                value={deviceNumber}
                help={
                  <React.Fragment>
                    <Typography color="textPrimary">
                      The light device number is a unique number that is required by the Individual Light Network. To obtain the device number:
                    </Typography>
                    <ol>
                      <li><Typography>Put the ANT+ light near the Garmin device</Typography></li>
                      <li><Typography>Open the Garmin menu and go to Sensors -&gt; Add Sensor -&gt; Light</Typography></li>
                      <li><Typography>The light with its device number (ID) should be displayed on the list</Typography></li>
                    </ol>
                    <img src="/DeviceNumber.png" alt="Example" />
                  </React.Fragment>
                }
              />
            </Grid>
            : null
          }
        </Grid>
        {
          modes && hasFilters
          ? <React.Fragment>
              <ElementWithHelp
                rootClass={classes.sectionTitle}
                element={<Typography variant="h5" color="textPrimary">Filter groups</Typography>}
                help={
                  <Typography color="textPrimary">
                    Filter groups contains a group of filters, which are used by the Smart mode to determine the light mode. Every filter group defines 
                    a light mode, which will be used when every filter condition inside the group is met. The order of filter groups is important
                    as in case multiple groups meet all their filters conditions, only the light mode of the first group will be used.
                  </Typography>
                }
              />
              <FilterGroups filterGroups={lightFilterGroups} lightModes={modes} device={device} />
          </React.Fragment>
          : null
        }
        {
          modes && lightPanel && device?.touchScreen
          ? <React.Fragment>
            <Typography variant="h5" className={classes.sectionTitle} color="textPrimary">Light panel</Typography>
            <LightPanel lightPanel={lightPanel} lightModes={modes} />
          </React.Fragment>
          : null
        }
        {
          modes && lightSettings && device?.settings
          ? <React.Fragment>
            <Typography variant="h5" className={classes.sectionTitle} color="textPrimary">Light settings</Typography>
            <LightSettings lightSettings={lightSettings} lightModes={modes} />
          </React.Fragment>
          : null
        }
      </CardContent>
    </Card>
    );
});
