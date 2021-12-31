import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import AppSelect from '../inputs/AppSelect';
import AppSlider from '../inputs/AppSlider';
import { operatorList, gpsAccuracyList } from '../constants';
import { observer } from 'mobx-react-lite';

export default observer(({ filter }) => {
  const getLabelText = (value) => {
    return gpsAccuracyList[value];
  };

  return (
  <Grid container spacing={3}>
    <Grid item xs={12} sm={12}>
    <Typography variant="h6">Values:</Typography>
      <ul>
        <li><Typography variant="button">N/A</Typography> - GPS is not available</li>
        <li><Typography variant="button">Last</Typography> - The Location is based on the last known GPS fix</li>
        <li><Typography variant="button">Poor</Typography> - The Location was calculated with a poor GPS fix. Only a 2-D GPS fix is available, likely due to a limited number of tracked satellites</li>
        <li><Typography variant="button">Ok</Typography> - The Location was calculated with a usable GPS fix. A 3-D GPS fix is available, with marginal HDOP (horizontal dilution of precision)</li>
        <li><Typography variant="button">Good</Typography> - The Location was calculated with a good GPS fix. A 3-D GPS fix is available, with good-to-excellent HDOP (horizontal dilution of precision)</li>
      </ul>
    </Grid>
    <Grid item xs={12} sm={4}>
      <AppSelect required items={operatorList} label="Operator" setter={filter.setOperator} value={filter.operator} /> 
    </Grid>
    <Grid item xs={12} sm={8}>
      <AppSlider
        label="Accuracy"
        setter={filter.setValue}
        value={filter.value}
        getLabelText={getLabelText}
        step={1}
        min={0}
        max={4}
        defaultValue={4}
      />
    </Grid>
  </Grid>
  );
});