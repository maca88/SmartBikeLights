import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import AppSelect from '../inputs/AppSelect';
import { observer } from 'mobx-react-lite';
import { setList } from '../constants';

export default observer(({ filter }) => {

  const setValue = (value) => {
    filter.setOperator('=');
    filter.setValue(value);
  };

  return (
  <Grid container spacing={3}>
    <Grid item xs={12} sm={12}>
      <Typography>
      NOTE: Start location is set when the activity is started and the GPS location is acquired. This filter can be 
      used to detect whether the activity is indoor or not.
      </Typography>
    </Grid>
    <Grid item xs={12} sm={4}>
      <AppSelect required items={setList} label="Value" setter={setValue} value={filter.value} /> 
    </Grid>
  </Grid>
  );
});