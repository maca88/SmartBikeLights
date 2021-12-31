import Grid from '@mui/material/Grid';
import AppTextInput from '../inputs/AppTextInput';
import { observer } from 'mobx-react-lite';

export default observer(({ filter }) => {

  const setValue = (value) => {
    filter.setOperator('=');
    filter.setValue(value);
  };

  return (
  <Grid container spacing={3}>
    <Grid item xs={12} sm={4}>
      <AppTextInput required label="Name" setter={setValue} value={filter.value} /> 
    </Grid>
  </Grid>
  );
});