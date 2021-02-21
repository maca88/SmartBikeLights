import Grid from '@material-ui/core/Grid';
import AppSelect from '../inputs/AppSelect';
import Typography from '@material-ui/core/Typography';
import AppTextInput from '../inputs/AppTextInput';
import AppSlider from '../inputs/AppSlider';
import { operatorList, vehicleThreatList } from '../constants';
import { observer } from 'mobx-react-lite';

const getLabelText = (value) => {
  return vehicleThreatList[value];
};

export default observer(({ label, filter }) => {
  return (
  <Grid container spacing={3}>
    <Grid item xs={12} sm={12}>
      <Typography style={{fontWeight:700}}>NOTE: This is an experimental filter!</Typography>
    </Grid>
    <Grid item xs={12} sm={4}>
      <AppSelect items={operatorList} label="Range operator" setter={filter.setOperator} value={filter.operator} /> 
    </Grid>
    {
      filter.operator ?
        <Grid item xs={12} sm={8}>
          <AppTextInput label="Vehicle range" type="number" setter={filter.setValue} value={filter.value} />
        </Grid>
      : <Grid item xs={12} sm={8}></Grid>
    }

    <Grid item xs={12} sm={4}>
      <AppSelect items={operatorList} label="Threat operator" setter={filter.setThreatOperator} value={filter.threatOperator} /> 
    </Grid>
    {
      filter.threatOperator ?
        <Grid item xs={12} sm={8}>
          <AppSlider
            label="Vehicle threat"
            setter={filter.setThreat}
            value={filter.threat}
            getLabelText={getLabelText}
            step={1}
            min={0}
            max={2}
            defaultValue={0}
          />
        </Grid>
      : <Grid item xs={12} sm={8}></Grid>
    }
  </Grid>
  );
});