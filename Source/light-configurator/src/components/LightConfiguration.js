import React, { useEffect } from 'react';
import { styled } from '@mui/material/styles';
import Typography from '@mui/material/Typography';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardHeader from '@mui/material/CardHeader';
import Grid from '@mui/material/Grid';
import { observer } from 'mobx-react-lite';
import FilterGroups from './FilterGroups';
import AppSelect from '../inputs/AppSelect';
import AppTextInput from '../inputs/AppTextInput';
import AppCheckbox from '../inputs/AppCheckbox';
import ElementWithHelp from './ElementWithHelp';
import LightPanel from './LightPanel';
import LightIconTapBehavior from './LightIconTapBehavior';
import LightSettings from './LightSettings';
import LightPanelModel from '../models/LightPanel';
import LightSettingsModel from '../models/LightSettings';
import LightIconTapBehaviorModel from '../models/LightIconTapBehavior';
import { getLightIconColors } from '../constants';

const PREFIX = 'LightConfiguration';

const classes = {
  sectionTitle: `${PREFIX}-sectionTitle`
};

const StyledCard = styled(Card)(({ theme }) => ({
  [`& .${classes.sectionTitle}`]: {
    marginTop: theme.spacing(3),
    marginBottom: theme.spacing(1),
  }
}));

const getModes = (value, lights) => {
  return value !== null ? lights.find(l => l.id === value)?.modes : null;
};

const getDefaultPanel = (value, lights) => {
  return value !== null ? lights.find(l => l.id === value)?.defaultLightPanel : null;
};

export default observer(({
  device, totalLights, useIndividualNetwork, globalFilterGroups, lightType, lightList, lightFilterGroups, setLight, light,
  setLightModes, setDefaultMode, defaultMode, lightPanel, setLightPanel, lightSettings, setLightSettings, deviceNumber, setDeviceNumber,
  serialNumber, setSerialNumber, forceSmartMode, setForceSmartMode, lightIconTapBehavior, setLightIconTapBehavior, lightIconColor, setLightIconColor }) => {
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
    if (lightIconTapBehavior == null && setLightIconTapBehavior != null) {
      setLightIconTapBehavior(new LightIconTapBehaviorModel());
    }
  }, [lightIconTapBehavior, setLightIconTapBehavior]);

  useEffect(() => {
    if (light == null) {
      setLightSettings(null);
    } else if (lightSettings == null) {
      setLightSettings(new LightSettingsModel(getDefaultPanel(light, lightList)));
    }
  }, [light, lightList, lightSettings, setLightSettings]);

  return (
    <StyledCard>
      <CardHeader
        title={lightType + ' Configuration'}
        titleTypographyProps={{ align: 'center' }}
      />
      <CardContent>
        <Grid container spacing={3}>
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
                  value={defaultMode}
                  help={
                    <React.Fragment>
                      <Typography>
                        The default mode is used only by the Smart control mode as a fallback light mode, when none of the below filter groups
                        is matched.
                      </Typography>
                    </React.Fragment>
                  }
                />
            </Grid>
            : null
          }
          {
            !light
            ? null
            : useIndividualNetwork && device?.highMemory
            ?
            <Grid item xs={12} sm={4}>
              <AppTextInput required label="Device number" type="number"
                setter={setDeviceNumber}
                value={deviceNumber}
                help={
                  <React.Fragment>
                    <Typography>
                      The light device number is a unique number that is required by the Individual Light Network. To obtain the device number:
                    </Typography>
                    <ol>
                      <li><Typography>Put the ANT+ light near the Garmin device</Typography></li>
                      <li><Typography>Open the Garmin menu and go to Sensors -&gt; Add Sensor -&gt; Light</Typography></li>
                      <li><Typography>The light with its device number (ID) should be displayed on the list</Typography></li>
                    </ol>
                    <img src="./DeviceNumber.png" alt="Example" />
                  </React.Fragment>
                }
              />
            </Grid>
            :
            <Grid item xs={12} sm={4}>
              <AppTextInput label="Serial number" type="number"
                setter={setSerialNumber}
                value={serialNumber}
                help={
                  <React.Fragment>
                    <Typography>
                      The light serial number which required only when multiple lights of the same type are paired (e.g. two headlights). To obtain the serial number:
                    </Typography>
                    <ol>
                      <li><Typography>Open the Garmin menu and go to Sensors -&gt; Lights</Typography></li>
                      <li><Typography>Select the desired light from the list and open About</Typography></li>
                      <li><Typography>The serial should be displayed with the label <b>Serial #</b></Typography></li>
                    </ol>
                  </React.Fragment>
                }
              />
            </Grid>
          }
          {
            light
            ?
            <Grid item xs={12} sm={4}>
              <AppSelect required items={getLightIconColors(device)} label="Icon color" setter={setLightIconColor} value={lightIconColor} />
            </Grid>
            : null
          }
          {
            setForceSmartMode && light && device?.highMemory
              ?
              <Grid item xs={12} sm={4}>
                <ElementWithHelp
                  element={
                    <AppCheckbox label="Force Smart mode" value={forceSmartMode} setter={setForceSmartMode} />
                  }
                  help={
                    <Typography>
                      Force Smart mode will prevent external light mode changes (e.g. pressing the button on the light) to switch from Smart
                      to Manual control mode. This setting works only when the light is in Smart control mode.
                    </Typography>
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
                sx={{marginBottom: 1, marginTop: 1}}
                element={<Typography variant="h5">Filter groups</Typography>}
                help={
                  <Typography>
                    Filter groups contains a group of filters, which are used by the Smart control mode to determine the light mode. Every filter group defines
                    a light mode, which will be used when every filter inside the group is matched. The order of filter groups is important
                    as in case multiple filter groups are matched, only the light mode of the topmost matched group will be used.
                  </Typography>
                }
              />
              <FilterGroups filterGroups={lightFilterGroups} lightModes={modes} device={device} totalLights={totalLights} />
          </React.Fragment>
          : null
        }
        {
          modes && lightIconTapBehavior && device?.touchScreen
          ? <React.Fragment>
              <ElementWithHelp
                className={classes.sectionTitle}
                element={<Typography variant="h5">Light icon tap behavior</Typography>}
                help={
                  <Typography>
                    Configure which control modes and light modes (for Manual mode) can be selected by tapping on the light icon.
                  </Typography>
                }
              />
              <LightIconTapBehavior lightIconTapBehavior={lightIconTapBehavior} lightModes={modes} />
          </React.Fragment>
          : null
        }
        {
          modes && lightPanel && device?.touchScreen
          ? <React.Fragment>
              <ElementWithHelp
                className={classes.sectionTitle}
                element={<Typography variant="h5">Light panel</Typography>}
                help={
                  <Typography>
                    The Light panel will be displayed only when putting the data field on a "1 Field Layout" data screen on your device. Here you can
                    modify how the light panel will look like on the screen by renaming buttons, order them in a different way, remove those that won't be
                    used, change to two buttons per row and change the short light name that will be displayed at the bottom of the screen.
                  </Typography>
                }
              />
            <LightPanel lightPanel={lightPanel} lightModes={modes} />
          </React.Fragment>
          : null
        }
        {
          modes && lightSettings && device?.settings
          ? <React.Fragment>
              <ElementWithHelp
                className={classes.sectionTitle}
                element={<Typography variant="h5">Light settings</Typography>}
                help={
                  <Typography>
                    The Light settings will be displayed when opening the data field settings on your device. Here you can modify how the menu for light
                    modes will be displayed by renaming items, order them in a different way, remove those that won't be used and change the short light name
                    that will be displayed in the menu.
                  </Typography>
                }
              />

            <LightSettings lightSettings={lightSettings} lightModes={modes} />
          </React.Fragment>
          : null
        }
      </CardContent>
    </StyledCard>
  );
});
