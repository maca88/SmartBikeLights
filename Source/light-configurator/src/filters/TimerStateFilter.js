import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
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
    <Grid item xs={12} sm={12}>
    <Typography variant="h6">Values:</Typography>
      <ul>
        <li><Typography variant="button">NR</Typography> - Not recording</li>
        <li><Typography variant="button">ST</Typography> - Recording stopped</li>
        <li><Typography variant="button">PA</Typography> - Recording paused</li>
        <li><Typography variant="button">RE</Typography> - Recording</li>
      </ul>
    </Grid>
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