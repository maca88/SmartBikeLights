import { TimePicker } from '@mui/x-date-pickers';
import TextField from '@mui/material/TextField';
import { observer } from 'mobx-react-lite';
import { useContext } from 'react';
import { AppContext } from '../AppContext';

export default observer(({ label, value, setter }) => {
  const context = useContext(AppContext);
  const handleChange = (newValue) => {
    setter(newValue);
  };

  if (!(value instanceof Date)) {
    value = '';
  }

  return (
    <TimePicker
      ampm={context.configuration.timeFormat === 1}
      label={label}
      value={value}
      onChange={handleChange}
      renderInput={(params) => (
        <TextField {...params} margin="normal" variant="standard" />
      )}
    />
  );
});
