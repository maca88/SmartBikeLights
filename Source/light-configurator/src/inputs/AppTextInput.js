import React from 'react';
import { nanoid } from 'nanoid';
import TextField from '@material-ui/core/TextField';
import HelpIcon from '@material-ui/icons/Help';
import InputAdornment from '@material-ui/core/InputAdornment';
import IconButton from '@material-ui/core/IconButton';
import Popper from '@material-ui/core/Popper';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import { makeStyles } from '@material-ui/core/styles';
import { observer } from 'mobx-react-lite';

const textInputUseStyles = makeStyles((theme) => ({
  input: {
    width: '100%',
  },
  popperContent: {
    maxWidth: 600,
    overflow: 'auto'
  },
}));

const removeInvalidCharacters = (value) => {
  if (!value){
    return value;
  }

  return value.replace(/[:|#]/g, '');
};

export default observer(({ type, label, value, setter, required, allowAllCharacters, help }) => {
  const id = nanoid();
  const classes = textInputUseStyles();
  const handleChange = (event) => {
    let newValue = event.target.value;
    setter(type === 'number'
      ? parseFloat(newValue)
      : !allowAllCharacters ? removeInvalidCharacters(newValue)
      : newValue);
  };
  // Help icon constants
  const [anchorEl, setAnchorEl] = React.useState(null);
  const handleClick = (event) => {
    setAnchorEl(anchorEl ? null : event.currentTarget);
  };
  const open = Boolean(anchorEl);
  const popperId = open ? `help-${id}` : undefined;

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
        endAdornment: help ?
          <InputAdornment position="end">
            <IconButton onClick={handleClick} >
              <HelpIcon color="primary" />
              <Popper placement="bottom" id={popperId} open={open} anchorEl={anchorEl}>
                <Card className={classes.popperContent}>
                  <CardContent>
                    {help}
                  </CardContent>
                </Card>
              </Popper>
            </IconButton>
          </InputAdornment>
          : null
      }}
    />
  );
});