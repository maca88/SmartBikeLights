import { useEffect } from 'react';
import { nanoid } from 'nanoid';
import TextField from '@mui/material/TextField';
import MenuItem from '@mui/material/MenuItem';
import Close from "@mui/icons-material/Close";
import React from 'react';
import IconButton from '@mui/material/IconButton';
import { observer } from "mobx-react-lite";
import AppInputHelp from './AppInputHelp';

export default observer(({ items, label, value, setter, required, help, multiple, itemTemplateFunc, disabled }) => {
  const id = nanoid();
  const defaultValue = multiple ? [] : '';
  const isDefault = (val) => multiple ? Array.isArray(val) && !val.length : val === '';
  const handleChange = (event) => {
    const newValue = event.target.value;
    if (multiple) {
      setter(newValue);
    } else {
      setter(!items.find(i => i.id === newValue) ? null : newValue);
    }
  };
  const renderNames = (ids) => {
    if (!ids)  {
      return '';
    }

    return ids.map(id => items.find(i => i.id === id)?.name).join(', ')
  };

  let resetValue = value != null && (!multiple && !items.find(i => i.id === value));
  useEffect(
    () => {
      if (resetValue) {
        setter(null);
      }

      if (value === null || multiple || value === '') {
        return;
      }

      if (!items.find(i => i.id === value)) {
        setter(null);
      }
    },
    [items, value, setter, multiple, resetValue]
  );

  if (value === null || resetValue) {
    value = defaultValue;
  }

  return (
    <TextField
      sx={{
        width: '100%'
      }}
      id={id}
      select
      required={required}
      error={ required && isDefault(value) ? true : false}
      label={label}
      value={value}
      onChange={handleChange}
      SelectProps={{
        multiple: multiple,
        renderValue: multiple ? renderNames : undefined
      }}
      variant="standard"
      InputProps={{
        readOnly: !setter,
        disabled: disabled,
        endAdornment: (
          setter && !required && !disabled && !isDefault(value) ?
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
        <MenuItem key={item.id} value={item.id}>{itemTemplateFunc ? itemTemplateFunc(item) : item.name}</MenuItem>
      ))}
    </TextField>
  );
});
