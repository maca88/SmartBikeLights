import React from 'react';
import { styled } from '@mui/material/styles';
import { action } from 'mobx';
import Grid from '@mui/material/Grid';
import { observer } from 'mobx-react-lite';
import { headlightList, taillightList, getDeviceLights } from '../constants';
import { getDevice, deviceList } from '../widgetConstants';
import AppSelect from '../inputs/AppSelect';
import LightConfiguration from './LightConfiguration';
import ConfigurationResult from './ConfigurationResult';
import IndividualLightNetwork from './IndividualLightNetwork';
import ParseConfiguration from './ParseConfiguration';

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

export default observer(({ configuration, setConfiguration }) => {
  const device = getDevice(configuration.device);
  const setNewDevice = action((newDevice) => {
    configuration.setDevice(newDevice);
  });
  const setNewConfiguration = action((newConfiguration) => {
    setConfiguration(newConfiguration);
  });

  return (
    <Root>
      <ParseConfiguration setConfiguration={setNewConfiguration} deviceList={deviceList} />
      <Grid container spacing={2} sx={{ marginBottom: 2 }} justifyContent="center">
        <Grid item xs={12} sm={12}>
          <AppSelect required items={deviceList} label="Garmin device" setter={setNewDevice} value={configuration.device} />
        </Grid>
      </Grid>
      <IndividualLightNetwork device={device} configuration={configuration} />
      { device ? (
        <React.Fragment>
          <LightConfiguration
            useIndividualNetwork={configuration.useIndividualNetwork}
            device={device}
            totalLights={configuration.getTotalLights()}
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
            serialNumber={configuration.headlightSerialNumber}
            setSerialNumber={configuration.setHeadlightSerialNumber}
            lightIconColor={configuration.headlightIconColor}
            setLightIconColor={configuration.setHeadlightIconColor}
          />
          <LightConfiguration
            useIndividualNetwork={configuration.useIndividualNetwork}
            device={device}
            totalLights={configuration.getTotalLights()}
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
            serialNumber={configuration.taillightSerialNumber}
            setSerialNumber={configuration.setTaillightSerialNumber}
            lightIconColor={configuration.taillightIconColor}
            setLightIconColor={configuration.setTaillightIconColor}
          />
          <ConfigurationResult
            configuration={configuration}
            deviceList={deviceList}
          />
        </React.Fragment>
      ) : null }
    </Root>
  );
});
