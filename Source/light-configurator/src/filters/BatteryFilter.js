import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import AppSelect from '../inputs/AppSelect';
import AppSlider from '../inputs/AppSlider';
import { operatorList, batteryStateList, getBatteryOperator, getBatteryValue } from '../constants';
import { observer } from 'mobx-react-lite';

export default observer(({ filter }) => {
  const getLabelText = (value) => {
    return batteryStateList[value];
  };
  const setValue = (value) => {
    filter.setValue(getBatteryValue(value));
  };
  const setOperator = (value) => {
    filter.setOperator(getBatteryOperator(value));
  };

  return (
  <Grid container spacing={3}>
    <Grid item xs={12} sm={12}>
      <Typography>
      NOTE: The battery state is not defined in percentage but rather as a number from one to five, where number one is "New" and five is "Bad". 
      Each number represents a percentage range (e.g. 50%-75%), where the range for each number may differ from light to light.
      </Typography>
    </Grid>
    <Grid item xs={12} sm={4}>
      <AppSelect required items={operatorList} label="Operator" setter={setOperator} value={getBatteryOperator(filter.operator)} /> 
    </Grid>
    <Grid item xs={12} sm={8}>
      <AppSlider
        label="Battery state"
        setter={setValue}
        value={getBatteryValue(filter.value)}
        getLabelText={getLabelText}
        step={1}
        min={1}
        max={5}
        defaultValue={5}
      />
    </Grid>
  </Grid>
  );
});