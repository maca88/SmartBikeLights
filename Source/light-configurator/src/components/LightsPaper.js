import Grid from '@mui/material/Grid';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';
import { observer } from 'mobx-react-lite';
import { getLight } from '../constants';

export default observer(({ configuration, getHeadlightNode, getTaillightNode, getMiddleNode }) => {

  const headlightId = configuration.headlight;
  const taillightId = configuration.taillight;
  const headlight = headlightId ? getLight(false, headlightId) : null;
  const taillight = taillightId ? getLight(true, taillightId) : null;

  return (
    <div>
      {
        headlight ?
          <Paper sx={{ padding: 2, marginBottom: 1 }}>
            <Grid container spacing={3} sx={{ marginBottom: 2 }}>
              <Grid item xs={12}>
                <Typography variant="h5">{headlight.name}</Typography>
              </Grid>
            </Grid>
            {getHeadlightNode(headlight)}
          </Paper>
          : null
      }
      {
        getMiddleNode != null ? getMiddleNode(headlight, taillight) : null
      }
      {
        taillight ?
          <Paper sx={{ padding: 2, marginBottom: 1 }}>
            <Grid container spacing={3} sx={{ marginBottom: 2 }}>
              <Grid item xs={12}>
                <Typography variant="h5">{taillight.name}</Typography>
              </Grid>
            </Grid>
            {getTaillightNode(taillight)}
          </Paper>
          : null
      }
    </div>
  );
});
