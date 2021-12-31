import { useEffect } from 'react';
import { nanoid } from 'nanoid';
import TextField from '@mui/material/TextField';
import MenuItem from '@mui/material/MenuItem';
import Close from "@mui/icons-material/Close";
import React from 'react';
import IconButton from '@mui/material/IconButton';
import { observer } from "mobx-react-lite";
import AppInputHelp from './AppInputHelp';

export default observer(({ items, label, value, setter, required, help }) => {
  const id = nanoid();
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

  if (value === null || !items.find(i => i.id === value)) {
    value = '';
  }

  return (
    <TextField
      sx={{
        width: '100%'
      }}
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
              size="large">
              <Close />
            </IconButton>
          </React.Fragment>
          : help ? <AppInputHelp content={help} style={{ marginRight: "1em", padding: '0' }} />
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
