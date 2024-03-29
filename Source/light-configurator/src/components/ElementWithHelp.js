import React from 'react';
import { styled } from '@mui/material/styles';
import { nanoid } from 'nanoid';
import Card from '@mui/material/Card';
import HelpIcon from '@mui/icons-material/Help';
import IconButton from '@mui/material/IconButton';
import CardContent from '@mui/material/CardContent';
import Popper from '@mui/material/Popper';

const PREFIX = 'ElementWithHelp';

const classes = {
  root: `${PREFIX}-root`
};

const Root = styled('div')(() => ({
  display: 'flex',
  alignItems: 'center',
  flexWrap: 'wrap'
}));

export default function ElementWithHelp({ element, help, className, ...props }) {
  const id = nanoid();
  const [anchorEl, setAnchorEl] = React.useState(null);
  const handleClick = (event) => {
    setAnchorEl(anchorEl ? null : event.currentTarget);
  };
  const open = Boolean(anchorEl);
  const popperId = open ? `help-${id}` : undefined;

  return (
    <Root {...props} className={`${classes.root} ${className ? className : ''}`}>
      {element}
      <IconButton onClick={handleClick} size="large">
        <HelpIcon color="primary" style={{ fontSize: 30, cursor: 'pointer' }} />
        <Popper placement="bottom" id={popperId} open={open} anchorEl={anchorEl}>
          <Card
            sx={{
              maxWidth: 600,
              overflow: 'auto'
            }}>
            <CardContent>
              {help}
            </CardContent>
          </Card>
        </Popper>
      </IconButton>
    </Root>
  );
}