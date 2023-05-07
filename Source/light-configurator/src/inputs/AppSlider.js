import { useEffect } from 'react';
import { nanoid } from 'nanoid';
import { styled } from '@mui/material/styles';
import PropTypes from 'prop-types';
import Slider from '@mui/material/Slider';
import Tooltip, { tooltipClasses } from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import { observer } from 'mobx-react-lite';

const BootstrapTooltip = styled(({ className, ...props }) => (
  <Tooltip {...props} arrow classes={{ popper: className }} />
))(({ theme }) => ({
  [`& .${tooltipClasses.arrow}`]: {
    color: theme.palette.primary.dark,
  },
  [`& .${tooltipClasses.tooltip}`]: {
    backgroundColor: theme.palette.primary.dark,
    fontSize: '14px'
  },
}));

function ValueLabelComponent(props) {
  const { children, open, value } = props;

  return (
    <BootstrapTooltip arrow open={open} enterTouchDelay={0} placement="top" title={value}>
      {children}
    </BootstrapTooltip>
  );
}

ValueLabelComponent.propTypes = {
  children: PropTypes.element.isRequired,
  open: PropTypes.bool.isRequired,
  value: PropTypes.any.isRequired,
};

const Root = styled('div')({
  width: '100%',
});

export default observer(({ label, value, setter, getLabelText, step, min, max, defaultValue, disabled }) => {
  const id = nanoid();
  const handleChange = (event, newValue) => {
    setter(newValue);
  };

  useEffect(() => {
    if (value == null) {
      setter(defaultValue);
    }
  }, [value, defaultValue, setter])

  return (
    <Root>
      <Typography id={id} gutterBottom>{label}</Typography>
      <Slider
        disabled={disabled}
        step={step}
        min={min}
        max={max}
        marks
        aria-labelledby={id}
        components={{
          ValueLabel: ValueLabelComponent
        }}
        valueLabelFormat={getLabelText}
        valueLabelDisplay="auto"
        value={value}
        onChange={handleChange} />
    </Root>
  );
});
