import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Button from '@material-ui/core/Button';
import Grid from '@material-ui/core/Grid';
import Alert from '@material-ui/core/Alert';
import AppTextInput from '../inputs/AppTextInput';
import Configuration from '../models/Configuration';
import { observer } from 'mobx-react-lite';

const useStyles = makeStyles((theme) => ({
  parseButtonCell: {
    marginBottom: 'auto',
    marginTop: 'auto'
  },
  parseButton: {
    width: '100%'
  },
  root: {
    marginBottom: theme.spacing(4)
  }
}));

export default observer(({ setConfiguration, deviceList }) => {
  const classes = useStyles();
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
    <Grid container className={classes.root} spacing={2} justify="center">
      <Grid item xs={8} sm={10}>
        <AppTextInput label="Existing configuration" value={state.existingConfigurationValue} setter={setExistingConfigurationValue} allowAllCharacters={true} />
      </Grid>
      <Grid item xs={4} sm={2} className={classes.parseButtonCell}>
        <Button className={classes.parseButton} variant="contained" onClick={() => {parse(state.existingConfigurationValue, deviceList)}}>Parse</Button>
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
