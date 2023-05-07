import React, { useEffect} from 'react';
import Grid from '@mui/material/Grid';
import Accordion from './Accordion';
import AccordionSummary from './AccordionSummary';
import AccordionDetails from './AccordionDetails';
import Filters from './Filters';
import { observer } from 'mobx-react-lite';
import AppSelect from '../inputs/AppSelect';
import { action } from 'mobx';
import { filterList, arrayMoveUp, arrayMoveDown, buttonTriggerList, buttonActionTypeList } from '../constants';
import { Typography } from '@mui/material';
import AddButton from './AddButton';
import Filter from '../models/Filter';
import CycleLightModes from '../actions/CycleLightModes';
import ChangeLightMode from '../actions/ChangeLightMode';
import ChangeConfiguration from '../actions/ChangeConfiguration';
import PlayTone from '../actions/PlayTone';

const excludeList = [
  'A', // Acceleration
  'B' // Light Battery
];

const filterTypes = filterList.filter(f => excludeList.indexOf(f.id) < 0);

const getButtonTriggers = (enableDoubleClick) => {
  return enableDoubleClick ? buttonTriggerList : buttonTriggerList.filter(t => t.id !== 3 /* Double-click */);
}

export default observer(({ configuration, device, actions, enableDoubleClick }) => {
  const [buttonTriggers, setButtonTriggers] = React.useState(getButtonTriggers(enableDoubleClick));
  useEffect(() => {
    setButtonTriggers(getButtonTriggers(enableDoubleClick));
  }, [enableDoubleClick, setButtonTriggers]);

  const removeAction = action((action) => {
    actions.remove(action);
  });
  const handleChange = (action) => {
    action.setOpen(!action.open);
  };
  const canMoveUpAction = (action) => {
    return actions.indexOf(action) > 0;
  };
  const moveUpAction = action((action) => {
    arrayMoveUp(actions, action);
  });
  const canMoveDownAction = (action) => {
    return actions.indexOf(action) < (actions.length - 1);
  };
  const moveDownAction = action((action) => {
    arrayMoveDown(actions, action);
  });
  const addActionCondition = action((action) => {
    action.conditions.push(new Filter());
  });

  return actions.map(action => (
    <Accordion key={action.id}
      TransitionProps={{ unmountOnExit: true }}
      expanded={action.open}
      onChange={() => handleChange(action)}>
        <AccordionSummary
          item={action}
          validationParameter={configuration}
          validationParameter2={device}
          removeCallback={removeAction}
          canMoveUpCallback={canMoveUpAction}
          moveUpCallback={moveUpAction}
          canMoveDownCallback={canMoveDownAction}
          moveDownCallback={moveDownAction}
        />
      <AccordionDetails>
        <Grid container spacing={3} sx={{ marginBottom: 3 }}>
          <Grid item xs={12} sm={6}>
            <AppSelect items={buttonActionTypeList} required label="Action type" setter={action.setActionType} value={action.actionType} />
          </Grid>
          <Grid item xs={12} sm={6}>
            <AppSelect items={buttonTriggers} required label="Trigger" setter={action.setTriggerId} value={action.triggerId} />
          </Grid>
        </Grid>

        {
          action.actionType === 1 /* Cycle light modes */ ? <CycleLightModes configuration={configuration} action={action} />
            : action.actionType === 2 /* Change light mode */ ? <ChangeLightMode configuration={configuration} action={action} />
            : action.actionType === 3 /* Change configuration */ ? <ChangeConfiguration action={action} />
            : action.actionType === 4 /* Play tone */ ? <PlayTone buttonAction={action} />
            : null
        }
        {
          action.actionType != null ?
            <Grid container spacing={3} sx={{ marginTop: 2 }}>
              <Grid item xs={12}>
                <Typography variant="h5" gutterBottom>Conditions</Typography>
              </Grid>
            </Grid>
            : null
        }
        {
          action.actionType != null ?
            <React.Fragment>
              <div>
                <Filters filters={action.conditions} filterTypes={filterTypes} device={device} />
              </div>
              <AddButton onClick={() => addActionCondition(action)}>
                Add Condition
              </AddButton>
            </React.Fragment>
          : null
        }
      </AccordionDetails>
    </Accordion>
  ));
});
