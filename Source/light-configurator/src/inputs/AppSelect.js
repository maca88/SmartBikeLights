import { useEffect } from 'react';
import { nanoid } from 'nanoid';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';
import Close from "@material-ui/icons/Close";
import React from 'react';
import IconButton from '@material-ui/core/IconButton';
import { makeStyles } from '@material-ui/core/styles';
import { observer } from "mobx-react-lite";

const selectUseStyles = makeStyles((theme) => ({
  input: {
    width: '100%',
  },
}));

export default observer(({ items, label, value, setter, required }) => {
  const id = nanoid();
  const classes = selectUseStyles();
  const handleChange = (event) => {
    const newValue = event.target.value;
    setter(!items.find(i => i.id === newValue) ? null : newValue);
  };

  useEffect(
    () => {
      if (value === null || value === '') {
        return;
      }

      if (!items.find(i => i.id === value)) {
        setter(null);
      }
    },
    [items, value, setter]
  );

  if (value === null) {
    value = '';
  }

  return (
    <TextField
      className={classes.input}
      id={id}
      select
      required={required}
      error={ required && value === '' ? true : false}
      label={label}
      value={value}
      onChange={handleChange}
      variant="standard"
      InputProps={{
        readOnly: !setter,
        endAdornment: (
          setter && !required && value !== '' ?
          <React.Fragment>
            <IconButton
              style={{ marginRight: "1em", padding: '0' }}
              onClick={() => setter(null)}
            >
              <Close />
            </IconButton>
          </React.Fragment>
          : null
        )
      }}
    >
      {items.map((item) => (
        <MenuItem key={item.id} value={item.id}>{item.name}</MenuItem>
      ))}
    </TextField>
  );
});
