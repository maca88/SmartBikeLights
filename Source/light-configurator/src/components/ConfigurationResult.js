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
import AppTextInput from '../inputs/AppTextInput';

const useStyles = makeStyles((theme) => ({
  copyButton: {
    marginTop: theme.spacing(4),
  },
  note: {
    fontWeight: 'bold'
  }
}));

export default observer(({ className, headerClassName, configuration, deviceList }) => {
  const classes = useStyles();
  const configurationValue = configuration.isValid(deviceList) ? configuration.getConfigurationValue(deviceList) : null;

  return (
    <Card className={className}>
      <CardHeader
        title="Lights Configuration"
        titleTypographyProps={{ align: 'center' }}
        className={headerClassName}
      />
      <CardContent>
        <Typography color="textPrimary" gutterBottom>
        When the lights are configured, copy the below value and paste it in the application setting "Lights Configuration" by using 
        Garmin Connect Mobile or Garmin Express.
        </Typography>
        {
          configurationValue && configurationValue.length > 256 ?
            <Typography color="textPrimary" className={classes.note} gutterBottom>
            NOTE: Do not use Garmin Express Mac as it is limited to 256 characters.
            </Typography>
          : null
        }
        { configurationValue ?
          <React.Fragment>
            <Grid item xs={12} sm={12}>
              <AppTextInput value={configurationValue} allowAllCharacters={true} />
            </Grid>
            <Grid item className={classes.copyButton} xs={12} sm={12}>
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
