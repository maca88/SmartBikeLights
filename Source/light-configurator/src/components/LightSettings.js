import React, { useCallback } from 'react';
import Grid from '@mui/material/Grid';
import { action } from 'mobx';
import { observer } from 'mobx-react-lite';
import LightButton from '../models/LightButton';
import ButtonGroup from './ButtonGroup';
import AddButton from './AddButton';
import AppTextInput from '../inputs/AppTextInput';

export default observer(({ lightSettings, lightModes, }) => {
  const moveButton = action(useCallback((dragIndex, hoverIndex) => {
      const dragButton = lightSettings.buttons[dragIndex]
      lightSettings.buttons.splice(dragIndex, 1);
      lightSettings.buttons.splice(hoverIndex, 0, dragButton);
    },
    [lightSettings.buttons],
  ));
  const addButton = action(() => {
    lightSettings.buttons.push(new LightButton());
  });
  const removeButton = action((button) => {
    lightSettings.buttons.remove(button);
  });

  return (
    <div>
      <Grid container spacing={3}>
        <Grid item xs={6} sm={4}>
          <AppTextInput label="Short light name" setter={lightSettings.setLightName} value={lightSettings.lightName} />
        </Grid>
      </Grid>
      <div>
        {lightSettings.buttons.map((button, index) => (
          <ButtonGroup
            key={button.id}
            buttonGroup={button}
            lightModes={lightModes}
            index={index}
            moveGroup={moveButton}
            addButton={addButton}
            removeButton={removeButton}
          />
        ))}
      </div>
      <AddButton onClick={() => addButton()}>
        Add Button
      </AddButton>
    </div>
  );
});
