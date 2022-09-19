import React from 'react';
import Button from '@mui/material/Button';
import Grid from '@mui/material/Grid';
import Alert from '@mui/material/Alert';
import AppTextInput from '../inputs/AppTextInput';
import Configuration from '../models/Configuration';
import { observer } from 'mobx-react-lite';

export default observer(({ setConfiguration, deviceList }) => {
  const [state, setState] = React.useState({
    existingConfigurationValue: null,
    parseError: false
  });
  const setExistingConfigurationValue = (value) => {
    setState({ ...state, existingConfigurationValue: value });
  };
  const parse = (value) => {
    let newConfiguration = null;
    try {
      newConfiguration = Configuration.parse(value, deviceList);
      if (!!newConfiguration) {
        setConfiguration(newConfiguration);
      }
    }
    catch {}
    finally {
      setState({
        existingConfigurationValue: null,
        parseError: !newConfiguration
      });
    }
  };

  return (
    <Grid container spacing={2} sx={{ marginBottom: 4 }} justifyContent="center">
      <Grid item xs={8} sm={10}>
        <AppTextInput label="Existing configuration" value={state.existingConfigurationValue} setter={setExistingConfigurationValue} allowAllCharacters={true} />
      </Grid>
      <Grid item xs={4} sm={2}
        sx={{
          marginBottom: 'auto',
          marginTop: 'auto'
        }}>
        <Button sx={{ width: '100%' }} variant="contained" onClick={() => {parse(state.existingConfigurationValue, deviceList)}}>Load</Button>
      </Grid>
      { state.parseError ?
        <Grid item xs={12} sm={12}>
          <Alert severity="error">Invalid configuration.</Alert>
        </Grid>
        : null
      }
    </Grid>
  );
});
