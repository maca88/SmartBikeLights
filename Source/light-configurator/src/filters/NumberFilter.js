import Grid from '@material-ui/core/Grid';
import AppSelect from '../inputs/AppSelect';
import AppTextInput from '../inputs/AppTextInput';
import { operatorList } from '../constants';
import { observer } from 'mobx-react-lite';

export default observer(({ label, filter }) => {
  return (
  <Grid container spacing={3}>
    <Grid item xs={12} sm={4}>
      <AppSelect required items={operatorList} label="Operator" setter={filter.setOperator} value={filter.operator} /> 
    </Grid>
    <Grid item xs={12} sm={8}>
      <AppTextInput required label={label} type="number" setter={filter.setValue} value={filter.value} />
    </Grid>
  </Grid>
  );
});