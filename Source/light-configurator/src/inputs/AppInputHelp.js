import React from 'react';
import { nanoid } from 'nanoid';
import HelpIcon from '@mui/icons-material/Help';
import InputAdornment from '@mui/material/InputAdornment';
import IconButton from '@mui/material/IconButton';
import Popper from '@mui/material/Popper';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import { observer } from 'mobx-react-lite';

export default observer(({ content, ...props }) => {
  const id = nanoid();
  // Help icon constants
  const [anchorEl, setAnchorEl] = React.useState(null);
  const handleClick = (event) => {
    setAnchorEl(anchorEl ? null : event.currentTarget);
  };
  const open = Boolean(anchorEl);
  const popperId = open ? `help-${id}` : undefined;

  return (
    <InputAdornment position="end" {...props}>
      <IconButton onClick={handleClick} size="large">
        <HelpIcon color="primary" />
        <Popper placement="bottom" id={popperId} open={open} anchorEl={anchorEl}>
          <Card
            sx={{
              maxWidth: 600,
              overflow: 'auto'
            }}>
            <CardContent>
              {content}
            </CardContent>
          </Card>
        </Popper>
      </IconButton>
    </InputAdornment>
  );
});