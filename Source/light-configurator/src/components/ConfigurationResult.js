import React from 'react';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import Grid from '@mui/material/Grid';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardHeader from '@mui/material/CardHeader';
import Alert from '@mui/material/Alert';
import { observer } from 'mobx-react-lite'
import AppTextInput from '../inputs/AppTextInput';

export default observer(({ configuration, deviceList, ...props }) => {
  const configurationValue = configuration.isValid(deviceList) ? configuration.getConfigurationValue(deviceList) : null;

  return (
    <Card {...props}>
      <CardHeader
        sx={{padding: 2}}
        title="Lights Configuration"
        titleTypographyProps={{ align: 'center' }}
      />
      <CardContent>
        <Typography gutterBottom>
        When the lights are configured, copy the below value and paste it in the application setting "Lights Configuration" by using 
        Garmin Connect Mobile or Garmin Express.
        </Typography>
        {
          configurationValue && configurationValue.length > 256 ?
            <Typography sx={{ fontWeight: 'bold' }} gutterBottom>
            NOTE: Do not use Garmin Express Mac as it is limited to 256 characters.
            </Typography>
          : null
        }
        { configurationValue ?
          <React.Fragment>
            <Grid item xs={12} sm={12}>
              <AppTextInput value={configurationValue} allowAllCharacters={true} />
            </Grid>
            <Grid item sx={{ marginTop: 4 }} xs={12} sm={12}>
              <Button variant="contained" onClick={() => {navigator.clipboard.writeText(configurationValue)}}>Copy to clipboard</Button>
            </Grid>
          </React.Fragment>
          :
          <Grid item xs={12} sm={12}>
            <Alert severity="error">Please fill the missing fields.</Alert>
          </Grid>
        }
      </CardContent>
    </Card>
  );
});
