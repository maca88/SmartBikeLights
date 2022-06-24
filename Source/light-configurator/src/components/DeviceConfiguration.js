import React from 'react';
import { styled } from '@mui/material/styles';
import Typography from '@mui/material/Typography';
import Grid from '@mui/material/Grid';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardHeader from '@mui/material/CardHeader';
import { observer } from 'mobx-react-lite'
import FilterGroups from './FilterGroups';
import LightConfiguration from './LightConfiguration';
import ConfigurationResult from './ConfigurationResult';
import ElementWithHelp from './ElementWithHelp';
import IndividualLightNetwork from './IndividualLightNetwork';
import { headlightList, taillightList, getDeviceLights } from '../constants';

const Root = styled('div')(({ theme }) => ({
  [`& .MuiCardHeader-root`]: {
    backgroundColor:
      theme.palette.mode === 'light'
        ? theme.palette.grey[200]
        : theme.palette.grey[700]
  },

  [`& .MuiCardHeader-root .ElementWithHelp-root`]: {
    justifyContent: 'center'
  },

  [`& .MuiCard-root`]: {
    marginTop: theme.spacing(2)
  }
}));

export default observer(({ configuration, device, deviceList }) => {
  return (
    <Root>
      <IndividualLightNetwork device={device} configuration={configuration} />
      <Card sx={{marginTop: 2}}>
        <CardHeader
          title={
            <ElementWithHelp
              element={<Typography variant="h5" align="center">Global Filters</Typography>}
              help={
                <Typography>
                  Global filters are the first filters that are checked by the Smart control mode to determine whether the lights can be turned on. In
                  case we define one or more global filters and none them is matched, then the lights won't be turned on. In case we don't define
                  any global filter or at least one of them is matched, then the light mode will be determine by the filters in the below Headlight/Taillight
                  Configuration section.
                </Typography>
              }
            />
          }
          titleTypographyProps={{ align: 'center' }}
          sx={{padding: 0.5}}
        />
        <CardContent>
          <Grid item xs={12} sm={12}>
            <ElementWithHelp
              sx={{marginBottom: 1}}
              element={<Typography variant="h5">Filter groups</Typography>}
              help={
                <React.Fragment>
                  <Typography>
                    Global filter groups contains a list of groups, where each group can have one or more filters, that are used by the Smart mode to determine
                    whether the lights can be turned on. A filter group is matched, when all filters inside it are matched. Rules:
                  </Typography>
                  <ul>
                    <li><Typography>When no filters groups are added or at least one of them is matched, the light mode will be determined by the below Headlight/Taillight Configuration section</Typography></li>
                    <li><Typography>When one or more filters groups are added and none of them is matched, then the lights won't be turned on</Typography></li>
                  </ul>
                  <Typography>
                   They are useful when having a condition that applies to all lights. For example, in case we want the lights to be turned on only when recording an activity.
                  </Typography>
                </React.Fragment>
              }
            />
          </Grid>
          <FilterGroups filterGroups={configuration.globalFilterGroups} device={device} totalLights={configuration.getTotalLights()} />
        </CardContent>
      </Card>

      <LightConfiguration
        globalFilterGroups={configuration.globalFilterGroups}
        useIndividualNetwork={configuration.useIndividualNetwork}
        device={device}
        totalLights={configuration.getTotalLights()}
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
        serialNumber={configuration.headlightSerialNumber}
        setSerialNumber={configuration.setHeadlightSerialNumber}
        forceSmartMode={configuration.headlightForceSmartMode}
        setForceSmartMode={configuration.setHeadlightForceSmartMode}
        lightIconTapBehavior={configuration.headlightIconTapBehavior}
        setLightIconTapBehavior={configuration.setHeadlightIconTapBehavior}
      />
      <LightConfiguration
        globalFilterGroups={configuration.globalFilterGroups}
        useIndividualNetwork={configuration.useIndividualNetwork}
        device={device}
        totalLights={configuration.getTotalLights()}
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
        serialNumber={configuration.taillightSerialNumber}
        setSerialNumber={configuration.setTaillightSerialNumber}
        forceSmartMode={configuration.taillightForceSmartMode}
        setForceSmartMode={configuration.setTaillightForceSmartMode}
        lightIconTapBehavior={configuration.taillightIconTapBehavior}
        setLightIconTapBehavior={configuration.setTaillightIconTapBehavior}
      />
      <ConfigurationResult
        configuration={configuration}
        deviceList={deviceList}
      />
    </Root>
  );
});
