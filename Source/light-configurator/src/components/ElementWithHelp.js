import React from 'react';
import { nanoid } from 'nanoid';
import { makeStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import HelpIcon from '@material-ui/icons/Help';
import IconButton from '@material-ui/core/IconButton';
import CardContent from '@material-ui/core/CardContent';
import Popper from '@material-ui/core/Popper';

const useStyles = makeStyles((theme) => ({
  root: {
    display: 'flex',
    alignItems: 'center',
    flexWrap: 'wrap'
  },
  card: {
    maxWidth: 600,
    overflow: 'auto'
  },
}));

export default function ElementWithHelp(props) {
  const id = nanoid();
  const classes = useStyles();
  const [anchorEl, setAnchorEl] = React.useState(null);
  const handleClick = (event) => {
    setAnchorEl(anchorEl ? null : event.currentTarget);
  };
  const open = Boolean(anchorEl);
  const popperId = open ? `help-${id}` : undefined;

  return (
    <div className={`${classes.root} ${props.rootClass}`}>
      {props.element}
      <IconButton onClick={handleClick} >
        <HelpIcon color="primary" style={{ fontSize: 30, cursor: 'pointer' }} />
        <Popper placement="bottom" id={popperId} open={open} anchorEl={anchorEl}>
          <Card className={classes.card}>
            <CardContent>
              {props.help}
            </CardContent>
          </Card>
        </Popper>
      </IconButton>
    </div>
  );
}