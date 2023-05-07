import React from 'react';
import Typography from '@mui/material/Typography';
import Grid from '@mui/material/Grid';
import List from '@mui/material/List';
import Accordion from './Accordion';
import AccordionSummary from './AccordionSummary';
import AccordionDetails from './AccordionDetails';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardHeader from '@mui/material/CardHeader';
import { action } from 'mobx';
import { observer } from 'mobx-react-lite'
import AppSelect from '../inputs/AppSelect';
import AppTextInput from '../inputs/AppTextInput';
import ElementWithHelp from './ElementWithHelp';
import AddButton from './AddButton';
import RemoteController from '../models/RemoteController';
import RemoteControllerButton from '../models/RemoteControllerButton';
import { remoteControllerList } from '../constants';
import RemoteControllerButtons from './RemoteControllerButtons';

export default observer(({ configuration, device, ...props }) => {

  const remoteControllers = configuration.remoteControllers;

  const addController = action(() => {
    remoteControllers.push(new RemoteController());
  });
  const removeController = action((remoteController) => {
    remoteControllers.remove(remoteController);
  });
  const handleChange = (remoteController) => {
    remoteController.setOpen(!remoteController.open);
  };
  const addControllerButton = action((remoteController) => {
    remoteController.buttons.push(new RemoteControllerButton(remoteController));
  });

  return (
    <Card {...props}>
      <CardHeader
        sx={{padding: 2}}
        title={
          <ElementWithHelp
            element={<Typography variant="h5" align="center">Remote Controllers (Experimental)</Typography>}
            help={
              <Typography>
                In this section it is possible to configure remote controllers (e.g. Bontrager Transmitr) to control lights, change current configuration or/and play tones.
              </Typography>
            }
          />
        }
        titleTypographyProps={{ align: 'center' }}
      />
      <CardContent>
        <div>
          <List sx={{ padding: 0 }}>
            {remoteControllers.map(remoteController => (
            <Accordion key={remoteController.id}
                  TransitionProps={{ unmountOnExit: true }}
                  expanded={remoteController.open}
                  onChange={() => handleChange(remoteController)}>
              <AccordionSummary
                item={remoteController}
                validationParameter={configuration}
                validationParameter2={device}
                removeCallback={removeController}
                canMoveUpCallback={() => false}
                canMoveDownCallback={() => false}
              />
              <AccordionDetails>
                <Grid container spacing={3}>
                  <Grid item xs={12} sm={6}>
                    <AppSelect items={remoteControllerList} required label="Remote controller" setter={remoteController.setControllerId} value={remoteController.controllerId} />
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <AppTextInput required label="Name" setter={remoteController.setName} value={remoteController.name} />
                  </Grid>
                  {
                    remoteController.controllerId != null ?
                      <Grid item xs={12} sm={12}>
                        <Typography variant="h5" gutterBottom>Buttons</Typography>
                      </Grid>
                    : null
                  }
                </Grid>
                {
                  remoteController.controllerId != null ?
                    <React.Fragment>
                      <div>
                        <RemoteControllerButtons remoteController={remoteController} configuration={configuration} device={device} buttons={remoteController.buttons} />
                      </div>
                      <AddButton onClick={() => addControllerButton(remoteController)}>
                        Setup Button
                      </AddButton>
                    </React.Fragment>
                  : null
                }
              </AccordionDetails>
            </Accordion>
            ))}
          </List>
          <div>
            <AddButton onClick={addController}>
              Add Controller
            </AddButton>
          </div>
        </div>

      </CardContent>
    </Card>
  );
});
