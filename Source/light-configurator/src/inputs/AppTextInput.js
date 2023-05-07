import { nanoid } from 'nanoid';
import TextField from '@mui/material/TextField';
import { observer } from 'mobx-react-lite';
import AppInputHelp from './AppInputHelp';

const removeInvalidCharacters = (value) => {
  if (!value){
    return value;
  }

  return value.replace(/[:|#]/g, '');
};

export default observer(({ type, label, value, setter, required, allowAllCharacters, help }) => {
  const id = nanoid();
  const handleChange = (event) => {
    let newValue = event.target.value;
    setter(type === 'number'
      ? parseFloat(newValue)
      : !allowAllCharacters ? removeInvalidCharacters(newValue)
      : newValue);
  };

  if (value === null || Number.isNaN(value)) {
    value = '';
  }

  return (
    <TextField
      sx={{
        width: '100%'
      }}
      id={id}
      label={label}
      required={required}
      error={required && value === '' ? true : false}
      variant="standard"
      type={type}
      value={value}
      onChange={handleChange}
      InputProps={{
        readOnly: !setter,
        endAdornment: help
          ? <AppInputHelp content={help} />
          : null
      }}
    />
  );
});
