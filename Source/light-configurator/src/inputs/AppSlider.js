import { nanoid } from 'nanoid';
import { makeStyles } from '@material-ui/core/styles';
import Slider from '@material-ui/core/Slider';
import Typography from '@material-ui/core/Typography';
import { observer } from 'mobx-react-lite';

const sliderMakeStyles = makeStyles((theme) => ({
  input: {
    width: '100%',
  },
}));

export default observer(({ label, value, setter, getLabelText, step, min, max, defaultValue }) => {
  const id = nanoid();
  const classes = sliderMakeStyles();
  const handleChange = (event, newValue) => {
    setter(newValue);
  };

  if (getLabelText != null && !getLabelText(value)) {
    value = defaultValue;
  }

  return (
    <div className={classes.input}>
      <Typography id={id} gutterBottom>{label}</Typography>
      <Slider
        step={step}
        min={min}
        max={max}
        marks
        aria-labelledby={id}
        valueLabelFormat={getLabelText}
        valueLabelDisplay="auto"
        value={value}
        onChange={handleChange} />
    </div>
  );
});