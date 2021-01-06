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
import LightPanel from './LightPanel';
import LightSettings from './LightSettings';
import LightPanelModel from '../models/LightPanel';
import LightSettingsModel from '../models/LightSettings';

const getModes = (value, lights) => {
  return value !== null ? lights.find(l => l.id === value).modes : null;
};

const getDefaultPanel = (value, lights) => {
  return value !== null ? lights.find(l => l.id === value).defaultLightPanel : null;
};

const useStyles = makeStyles((theme) => ({
  sectionTitle: {
    'margin-top': theme.spacing(3),
    'margin-bottom': theme.spacing(1),
  }
}));

export default observer(({
  className, headerClassName, device, globalFilterGroups, lightType, lightList, lightFilterGroups, setLight, light,
  setLightModes, setDefaultMode, defaultMode, lightPanel, setLightPanel, lightSettings, setLightSettings }) => {
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
        {
          hasFilters
          ?
          <Typography color="textPrimary" gutterBottom>
          In order to configure the light, the correct light should be selected as every light supports only a few modes from the "ANT+ Bike Lights Device Profile" 
          and may differ from light to light. In case your light is not on the list, please feel free to open an issue on GitHub or select "Unknown" option. The 
          "Unknown" option includes all the available options from the ANT+ profile and should only be used to test which modes your light supports. In case an 
          unsupported mode is selected, the application will display an error code on the screen. When the correct light is selected, then you can define filters that 
          triggers a certain light mode and set the default mode, which will be used when none of the defined filters evaluate to true. The filter logic is the same 
          as for global filters, where all filters inside a filter group need to be true in order the filter group light mode to be used. In case having multiple 
          filter groups, the light mode of the first filter group to be evaluated to true, will be used.
          </Typography>
          : null
        }

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
        </Grid>
        {
          modes && hasFilters
          ? <React.Fragment>
              <Typography variant="h5" className={classes.sectionTitle} color="textPrimary">Filter groups</Typography>
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
