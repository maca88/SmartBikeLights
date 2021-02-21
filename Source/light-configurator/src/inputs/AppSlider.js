import { nanoid } from 'nanoid';
import PropTypes from 'prop-types';
import { makeStyles } from '@material-ui/core/styles';
import Slider from '@material-ui/core/Slider';
import Tooltip from '@material-ui/core/Tooltip';
import Typography from '@material-ui/core/Typography';
import { observer } from 'mobx-react-lite';

const labelUseStyles = makeStyles((theme) => ({
  arrow: {
    color: theme.palette.primary.dark,
  },
  tooltip: {
    backgroundColor: theme.palette.primary.dark,
    fontSize: '14px'
  },
}));

function ValueLabelComponent(props) {
  const classes = labelUseStyles();
  const { children, open, value } = props;

  return (
    <Tooltip arrow open={open} enterTouchDelay={0} classes={classes} placement="top" title={value}>
      {children}
    </Tooltip>
  );
}

ValueLabelComponent.propTypes = {
  children: PropTypes.element.isRequired,
  open: PropTypes.bool.isRequired,
  value: PropTypes.any.isRequired,
};

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
        ValueLabelComponent={ValueLabelComponent}
        valueLabelFormat={getLabelText}
        valueLabelDisplay="auto"
        value={value}
        onChange={handleChange} />
    </div>
  );
});