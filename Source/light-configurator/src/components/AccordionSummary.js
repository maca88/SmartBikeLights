import MuiAccordionSummary from '@material-ui/core/AccordionSummary';
import IconButton from '@material-ui/core/IconButton';
import DeleteIcon from '@material-ui/icons/Delete';
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

export default observer(({ item, param1, removeLabel, removeCallback }) => {
  const classes = useStyles();
  return <AccordionSummary
    expandIcon={<ExpandMoreIcon />}
    aria-controls={item.id}
    id={item.id}
  >
    <div style={{ width: '100%' }}>
      <Grid container>
        <Grid item xs={2} sm={1}>
          <FormControlLabel
            aria-label={removeLabel}
            onClick={(event) => event.stopPropagation()}
            onFocus={(event) => event.stopPropagation()}
            control={
            <IconButton edge="end" aria-label="delete" onClick={() => removeCallback(item)}>
              <DeleteIcon />
            </IconButton>
            }
          />
        </Grid>
        <Grid item xs={9} sm={10} className={classes.name} >
          <Typography >{item.getDisplayName(param1)}</Typography>
        </Grid>
        <Grid item xs={1} sm={1} className={classes.error} >
        { item.isValid() ? null : <ErrorOutlineIcon /> }
        </Grid>
      </Grid>
    </div>
  </AccordionSummary>
});