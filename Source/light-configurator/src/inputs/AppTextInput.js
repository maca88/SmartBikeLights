import { nanoid } from 'nanoid';
import TextField from '@material-ui/core/TextField';
import { makeStyles } from '@material-ui/core/styles';
import { observer } from 'mobx-react-lite';

const textInputUseStyles = makeStyles((theme) => ({
  input: {
    width: '100%',
  },
}));

export default observer(({ type, label, value, setter, required }) => {
  const id = nanoid();
  const classes = textInputUseStyles();
  const handleChange = (event) => {
    let newValue = event.target.value;
    setter(type === 'number' ? parseFloat(newValue) : newValue);
  };

  if (value === null || Number.isNaN(value)) {
    value = '';
  }

  return (
    <TextField
      id={id}
      className={classes.input}
      label={label}
      required={required}
      error={required && value === '' ? true : false}
      variant="standard"
      type={type}
      value={value}
      onChange={handleChange}
      InputProps={{
        readOnly: !setter,
      }}
    />
  );
});