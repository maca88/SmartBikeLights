import Grid from '@mui/material/Grid';
import AppSelect from '../inputs/AppSelect';
import AppSlider from '../inputs/AppSlider';
import { operatorList, timerStateList } from '../constants';
import { observer } from 'mobx-react-lite';

export default observer(({ filter }) => {
  const getLabelText = (value) => {
    return timerStateList[value];
  };

  return (
  <Grid container spacing={3}>
    <Grid item xs={12} sm={4}>
      <AppSelect required items={operatorList} label="Operator" setter={filter.setOperator} value={filter.operator} /> 
    </Grid>
    <Grid item xs={12} sm={8}>
      <AppSlider
        label="Timer state"
        setter={filter.setValue}
        value={filter.value}
        getLabelText={getLabelText}
        step={1}
        min={0}
        max={3}
        defaultValue={0}
      />
    </Grid>
  </Grid>
  );
});