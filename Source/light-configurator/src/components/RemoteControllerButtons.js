import React from 'react';
import { action } from 'mobx';
import { observer } from 'mobx-react-lite';
import Grid from '@mui/material/Grid';
import { Typography } from '@mui/material';
import Accordion from './Accordion';
import AccordionSummary from './AccordionSummary';
import AccordionDetails from './AccordionDetails';
import AddButton from './AddButton';
import ElementWithHelp from './ElementWithHelp';
import RemoteControllerButtonActions from './RemoteControllerButtonActions';
import AppSelect from '../inputs/AppSelect';
import AppCheckbox from '../inputs/AppCheckbox';
import AppTextInput from '../inputs/AppTextInput';
import RemoteControllerButtonAction from '../models/RemoteControllerButtonAction';

export default observer(({ configuration, device, remoteController, buttons }) => {
  const removeButton = action((button) => {
    buttons.remove(button);
  });
  const handleChange = (button) => {
    button.setOpen(!button.open);
  };
  const addButtonAction = action((button) => {
    button.actions.push(new RemoteControllerButtonAction());
  });

  return buttons.map(button => (
    <Accordion key={button.id}
      TransitionProps={{ unmountOnExit: true }}
      expanded={button.open}
      onChange={() => handleChange(button)}>
      <AccordionSummary
        item={button}
        validationParameter={configuration}
        validationParameter2={device}
        removeCallback={removeButton}
        canMoveUpCallback={() => false}
        canMoveDownCallback={() => false}
      />
      <AccordionDetails>
        <Grid container spacing={3}>
          <Grid item xs={12} sm={6}>
            <AppSelect items={remoteController.buttonSelectList} required label="Button" setter={button.setButtonId} value={button.buttonId} />
          </Grid>
          <Grid item xs={12} sm={6}>
            {
              remoteController.hasStandaloneCenterButton() || button.buttonId !== 1 /* Center */ ?
              <AppTextInput required label="Device number" type="number"
                  setter={button.setDeviceNumber}
                  value={button.deviceNumber}
                  help={
                    <React.Fragment>
                      <Typography>
                        The device number that will be used for the virtual ANT+ light. Do note that changing the device number after the pairing is done will require repeating the pairing process.
                      </Typography>
                    </React.Fragment>
                  }
                />
              : null
            }
          </Grid>
          <Grid item xs={12} sm={6}>
            <ElementWithHelp
              element={
                <AppCheckbox label="Enable double-click" setter={button.setEnableDoubleClick} value={button.enableDoubleClick} />
              }
              help={
                <Typography gutterBottom>
                  By enabling double-click detection, the action will be delayed up to the set delay as it waits for the second click.
                  If the second click is received after the specified delay, the logic will treat both clicks as single-click.
                </Typography>
              }
            />
          </Grid>
          {
            button.enableDoubleClick ?
            <Grid item xs={12} sm={6}>
              <AppTextInput required label="Double-click delay" type="number" setter={button.setDoubleClickDelay} value={button.doubleClickDelay} />
            </Grid>
            : null
          }
          {
            button.buttonId != null ?
              <Grid item xs={12} sm={12}>
                <Typography variant="h5" gutterBottom>Actions</Typography>
              </Grid>
            : null
          }

        </Grid>
        {
          button.buttonId != null ?
            <React.Fragment>
              <div>
                <RemoteControllerButtonActions configuration={configuration} device={device} actions={button.actions} enableDoubleClick={button.enableDoubleClick} />
              </div>
              <AddButton onClick={() => addButtonAction(button)}>
                Add Action
              </AddButton>
            </React.Fragment>
          : null
        }
      </AccordionDetails>
    </Accordion>
  ));
});
