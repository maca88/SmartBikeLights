import React from 'react';
import { action } from 'mobx';
import Grid from '@mui/material/Grid';
import { observer } from 'mobx-react-lite';
import { timeFormatList, unitList, getSeparatorColors } from '../constants';
import AppSelect from '../inputs/AppSelect';
import DeviceConfiguration from './DeviceConfiguration';
import ParseConfiguration from './ParseConfiguration';
import UserConfigurations from './UserConfigurations';
import { createMenuItemColorTemplateFunc } from './Templates';
import { getDevice, deviceList } from '../dataFieldConstants';
import { Alert, Link } from '@mui/material';

const itemTemplate = createMenuItemColorTemplateFunc();

export default observer(({ configuration, setConfiguration, currentUser }) => {
  const setNewConfiguration = action((newConfiguration) => {
    setConfiguration(newConfiguration);
  });

  return (
    <div>
      <Alert severity="info">
        Hard to understand? <Link target="_blank" rel="noopener" href="https://github.com/maca88/SmartBikeLights/wiki/Lights-Configurator">Check the documentation</Link>
      </Alert>
      <UserConfigurations configuration={configuration} setConfiguration={setConfiguration} deviceList={deviceList} currentUser={currentUser} />
      <ParseConfiguration setConfiguration={setNewConfiguration} deviceList={deviceList} />
      <Grid container spacing={2} sx={{ marginBottom: 2 }} justifyContent="center">
        <Grid item xs={12} sm={4}>
          <AppSelect required items={deviceList} label="Garmin device" setter={configuration.setDevice} value={configuration.device} />
        </Grid>
        <Grid item xs={6} sm={4}>
          <AppSelect required items={unitList} label="Units" setter={configuration.setUnits} value={configuration.units} />
        </Grid>
        <Grid item xs={6} sm={4}>
          <AppSelect required items={timeFormatList} label="Time format" setter={configuration.setTimeFormat} value={configuration.timeFormat} />
        </Grid>
      </Grid>
      { configuration.device ?
        <div>
          <Grid container spacing={2} sx={{ marginBottom: 2 }} justifyContent="left">
            <Grid item xs={12} sm={4}>
              <AppSelect required items={getSeparatorColors(getDevice(configuration.device))} label="Separator color" setter={configuration.setSeparatorColor} value={configuration.separatorColor} itemTemplateFunc={itemTemplate} />
            </Grid>
          </Grid>
          <DeviceConfiguration configuration={configuration} device={getDevice(configuration.device)} deviceList={deviceList} />
        </div>
        : null
      }
    </div>
  );
});
