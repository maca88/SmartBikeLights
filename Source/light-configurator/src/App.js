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

export default observer(() => {
  var appTitle = process.env.REACT_APP_TITLE;
  var appType = getAppType();
  const DataField = React.lazy(() => import('./components/DataFieldConfiguration'));
  const Widget = React.lazy(() => import('./components/WidgetConfiguration'));
  const prefersDarkMode = useMediaQuery('(prefers-color-scheme: dark)');
  const { deviceList } = appType === 'datafield'
    ? require('./dataFieldConstants')
    : require('./widgetConstants');
  const [state, setState] = React.useState(getContextValue(prefersDarkMode ? 'dark' : 'light', getDefaultConfiguration(deviceList)));
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
    var newTheme = createTheme({
      palette: {
        mode: state.theme
      },
    });
    document.body.style = `background-color: ${newTheme.palette.background.paper};`;
    return newTheme;
  },
  [state.theme]);

  return (
    <AppContext.Provider value={state}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <AppBar position="relative">
          <Toolbar>
            <Typography variant="h6" color="inherit" noWrap sx={{ flexGrow: 1 }}>
              Lights Configurator ({appTitle})
            </Typography>
            <IconButton sx={{ ml: 1 }} onClick={toggleTheme} color="inherit">
              {theme.palette.mode === 'dark' ? <Brightness7Icon /> : <Brightness4Icon />}
            </IconButton>
          </Toolbar>
        </AppBar>
        <main>
          <MainContent>
            <Container maxWidth="md">
              <React.Suspense fallback={<></>}>
                {appType === 'datafield' && <DataField configuration={state.configuration} setConfiguration={setConfiguration} />}
                {appType === 'widget' && <Widget configuration={state.configuration} setConfiguration={setConfiguration} />}
              </React.Suspense>
            </Container>
          </MainContent>
        </main>
      </ThemeProvider>
    </AppContext.Provider>
  );
});
