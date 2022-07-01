import React, { useEffect, useMemo } from 'react';
import useMediaQuery from '@mui/material/useMediaQuery';
import { styled } from '@mui/material/styles';
import Container from '@mui/material/Container';
import AppBar from '@mui/material/AppBar';
import Typography from '@mui/material/Typography';
import CssBaseline from '@mui/material/CssBaseline';
import Toolbar from '@mui/material/Toolbar';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import IconButton from '@mui/material/IconButton';
import Brightness4Icon from '@mui/icons-material/Brightness4';
import Brightness7Icon from '@mui/icons-material/Brightness7';
import { observer } from 'mobx-react-lite';
import Configuration from './models/Configuration';
import { AppContext, getContextValue } from './AppContext';
import { getAppType } from './constants'
const classes = {
  hidden: `hidden-md`
};

const StyledAppBar = styled(AppBar)(({ theme }) => ({
  [`& .${classes.hidden}`]: {
    [theme.breakpoints.up('md')]: {
      display: 'none !important',
    }
  }
}));

const MainContent = styled('div')(({ theme }) => ({
  backgroundColor: theme.palette.background.paper,
  padding: theme.spacing(8, 0, 6)
}));

const getDefaultConfiguration = (deviceList) => {
  var parameterValue = new URLSearchParams(window.location.search).get('c');
  if (parameterValue) {
    try {
      return Configuration.parse(atob(parameterValue), deviceList);
    }
    catch {}
  }

  return new Configuration();
}

const appType = getAppType();

let FirebaseService = null;
let SignIn = null;
if (appType === 'datafield') {
  FirebaseService = require('./services/FirebaseService').default;
  FirebaseService.initialize();
  SignIn = require('./components/SignIn').default;
}

export default observer(() => {
  const appTitle = process.env.REACT_APP_TITLE;
  const { deviceList } = appType === 'datafield'
    ? require('./dataFieldConstants')
    : require('./widgetConstants');
  const DataField = React.lazy(() => import('./components/DataFieldConfiguration'));
  const Widget = React.lazy(() => import('./components/WidgetConfiguration'));
  const prefersDarkMode = useMediaQuery('(prefers-color-scheme: dark)');
  const [state, setState] = React.useState(getContextValue(prefersDarkMode ? 'dark' : 'light', getDefaultConfiguration(deviceList), null));
  const setTheme = useMemo(() =>
    (theme) => {
      setState((prevState) => {
        return { ...prevState, theme: theme };
      })
    },
    []);
  const toggleTheme = () => {
    setTheme(state.theme === 'light' ? 'dark' : 'light');
  };
  const setConfiguration = (configuration) => {
    setState((prevState) => {
      return { ...prevState, configuration: configuration };
    })
  };

  useEffect(() => {
    setTheme(prefersDarkMode ? 'dark' : 'light');
  }, [prefersDarkMode, setTheme]);

  const theme = useMemo(() => {
    const newTheme = createTheme({
      palette: {
        mode: state.theme
      },
    });
    document.body.style = `background-color: ${newTheme.palette.background.paper};`;
    return newTheme;
  },
  [state.theme]);

  useEffect(() => {
    if (!FirebaseService) {
      return;
    }

    return FirebaseService.subscribeOnUserChanged(user => {
      setState((prevState) => {
        return { ...prevState, currentUser: user };
      })
    });
  }, []);

  return (
    <AppContext.Provider value={state}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <StyledAppBar position="relative">
          <Toolbar>
            <Typography variant="h6" color="inherit" noWrap sx={{ flexGrow: 1 }}>
              Lights Configurator <br className={classes.hidden} /> ({appTitle})
            </Typography>
            {
              SignIn ? <SignIn /> : null
            }
            <IconButton sx={{ ml: 1 }} onClick={toggleTheme} color="inherit">
              {theme.palette.mode === 'dark' ? <Brightness7Icon /> : <Brightness4Icon />}
            </IconButton>
          </Toolbar>
        </StyledAppBar>
        <main>
          <MainContent>
            <Container maxWidth="md">
              <React.Suspense fallback={<></>}>
                {appType === 'datafield' && <DataField configuration={state.configuration} setConfiguration={setConfiguration} currentUser={state.currentUser} />}
                {appType === 'widget' && <Widget configuration={state.configuration} setConfiguration={setConfiguration} />}
              </React.Suspense>
            </Container>
          </MainContent>
        </main>
      </ThemeProvider>
    </AppContext.Provider>
  );
});
