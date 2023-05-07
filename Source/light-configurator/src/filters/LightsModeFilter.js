import Grid from '@mui/material/Grid';
import { AppContext } from '../AppContext';
import LightModeSelection from '../components/LightModeSelection';
import { observer } from 'mobx-react-lite';
import LightsPaper from '../components/LightsPaper';
import AppSelect from '../inputs/AppSelect';
import { logicalOperators } from '../constants';

export default observer(({ filter }) => {

  const headlightMode = filter.headlightMode;
  const taillightMode = filter.taillightMode;
  const bothSet = headlightMode.controlMode != null && taillightMode.controlMode != null;

  return (
    <AppContext.Consumer>
      {(context) => (
        <LightsPaper
          configuration={context.configuration}
          getHeadlightNode={(headlight) => (
            <LightModeSelection
              controlMode={headlightMode.controlMode} setControlMode={headlightMode.setControlMode}
              lightMode={headlightMode.lightMode} setLightMode={headlightMode.setLightMode} lightModes={headlight.modes}
              operator={headlightMode.operator} setOperator={headlightMode.setOperator} />
          )}
          getMiddleNode={(headlight, taillight) => (
            headlight && taillight ?
            <Grid container spacing={3} sx={{ marginBottom: 2 }}>
              <Grid item xs={12} sm={4}>
                <AppSelect required={bothSet} items={logicalOperators} label="Operator" setter={filter.setOperator} value={filter.operator} />
              </Grid>
            </Grid>
            : null
          )}
          getTaillightNode={(taillight) => (
            <LightModeSelection
              controlMode={taillightMode.controlMode} setControlMode={taillightMode.setControlMode}
              lightMode={taillightMode.lightMode} setLightMode={taillightMode.setLightMode} lightModes={taillight.modes}
              operator={taillightMode.operator} setOperator={taillightMode.setOperator} />
          )}
        />
      )}
    </AppContext.Consumer>
  );
});
