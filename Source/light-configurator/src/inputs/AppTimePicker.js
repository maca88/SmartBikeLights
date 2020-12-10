import TimePicker from '@material-ui/lab/TimePicker';
import TextField from '@material-ui/core/TextField';
import { observer } from 'mobx-react-lite';
import { AppContext } from '../AppContext';

export default observer(({ label, value, setter }) => {
  const handleChange = (newValue) => {
    setter(newValue);
  };

  if (!(value instanceof Date)) {
    value = '';
  }

  return (
    <AppContext.Consumer>
      {({timeFormat}) => (
        <TimePicker
          ampm={timeFormat === 1}
          label={label}
          value={value}
          onChange={handleChange}
          renderInput={(params) => (
            <TextField {...params} margin="normal" variant="standard" />
          )}
        />
      )}
    </AppContext.Consumer>
  );
});