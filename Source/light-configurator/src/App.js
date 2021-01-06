import React from 'react';
import AppBar from '@material-ui/core/AppBar';
import Container from '@material-ui/core/Container';
import Typography from '@material-ui/core/Typography';
import CssBaseline from '@material-ui/core/CssBaseline';
import Toolbar from '@material-ui/core/Toolbar';
import { makeStyles } from '@material-ui/core/styles';
import { observer } from 'mobx-react-lite';

const useStyles = makeStyles((theme) => ({
  mainContent: {
    backgroundColor: theme.palette.background.paper,
    padding: theme.spacing(8, 0, 6)
  }
}));

export default observer(() => {
  const classes = useStyles();

  var appType = process.env.REACT_APP_TYPE;
  const DataField = React.lazy(() => import('./components/DataFieldConfiguration'));
  const Widget = React.lazy(() => import('./components/WidgetConfiguration'));

  return (
    <React.Fragment>
      <CssBaseline />
      <AppBar position="relative">
        <Toolbar>
          <Typography variant="h6" color="inherit" noWrap>
            Lights Configurator
          </Typography>
        </Toolbar>
      </AppBar>
      <main>
        <div className={classes.mainContent}>
          <Container maxWidth="md">
            <React.Suspense fallback={<></>}>
              {appType === 'datafield' && <DataField />}
              {appType === 'widget' && <Widget />}
            </React.Suspense>
          </Container>
        </div>
      </main>
    </React.Fragment>
    );
});
