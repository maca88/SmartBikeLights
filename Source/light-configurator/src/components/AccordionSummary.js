import React from 'react';
import MuiAccordionSummary from '@material-ui/core/AccordionSummary';
import IconButton from '@material-ui/core/IconButton';
import DeleteIcon from '@material-ui/icons/Delete';
import ArrowDownwardIcon from '@material-ui/icons/ArrowDownward';
import ArrowUpwardIcon from '@material-ui/icons/ArrowUpward';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import Typography from '@material-ui/core/Typography';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import ErrorOutlineIcon from '@material-ui/icons/ErrorOutline';
import Grid from '@material-ui/core/Grid';
import { withStyles, makeStyles } from '@material-ui/core/styles';
import { observer } from 'mobx-react-lite';

const AccordionSummary = withStyles({
  root: {
    backgroundColor: 'rgba(0, 0, 0, .03)',
    borderBottom: '1px solid rgba(0, 0, 0, .125)',
    marginBottom: -1,
    minHeight: 56,
    '&$expanded': {
      minHeight: 56
    }
  },
  content: {
    '&$expanded': {
      margin: '12px 0'
    }
  },
  expanded: {},
})(MuiAccordionSummary);

const useStyles = makeStyles((theme) => ({
  name: {
    display: 'flex',
    alignItems: 'center',
  },
  error: {
    color: '#f44336',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
  }
}));

export default observer(({ item, param1, removeLabel, removeCallback, moveUpCallback, canMoveUpCallback,
  canMoveDownCallback, moveDownCallback, validationParameter, validationParameter2 }) => {
  const classes = useStyles();
  const isValid = validationParameter2
    ? item.isValid(validationParameter, validationParameter2)
    : item.isValid(validationParameter);

  return <AccordionSummary
    expandIcon={<ExpandMoreIcon />}
    aria-controls={item.id}
    id={item.id}
  >
    <div style={{ width: '100%' }}>
      <Grid container>
        <Grid item xs={9} sm={3}>
          <FormControlLabel
            aria-label={removeLabel}
            onClick={(event) => event.stopPropagation()}
            onFocus={(event) => event.stopPropagation()}
            control={
              <IconButton aria-label="delete" onClick={() => removeCallback(item)}>
                <DeleteIcon />
              </IconButton>
            }
          />
          {
            canMoveUpCallback(item)
            ? <FormControlLabel
                onClick={(event) => event.stopPropagation()}
                onFocus={(event) => event.stopPropagation()}
                control={
                  <IconButton onClick={() => moveUpCallback(item)}>
                    <ArrowUpwardIcon />
                  </IconButton>
                } />
            : null
          }
          {
            canMoveDownCallback(item)
            ? <FormControlLabel
                onClick={(event) => event.stopPropagation()}
                onFocus={(event) => event.stopPropagation()}
                control={
                  <IconButton edge="end" onClick={() => moveDownCallback(item)}>
                    <ArrowDownwardIcon />
                  </IconButton>
                } />
            : null
          }
        </Grid>
        {
          isValid
          ? <Grid item xs={10} sm={8} className={classes.name} >
              <Typography>{item.getDisplayName(param1)}</Typography>
            </Grid>
          : <Grid item xs={1} sm={8} className={classes.name} >
            </Grid>
        }
        <Grid item xs={2} sm={1} className={classes.error} >
        { isValid ? null : <ErrorOutlineIcon /> }
        </Grid>
      </Grid>
    </div>
  </AccordionSummary>
});