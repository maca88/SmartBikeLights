import React, { useEffect, useCallback } from 'react';
import Grid from '@mui/material/Grid';
import { action } from 'mobx';
import { observer } from 'mobx-react-lite';
import LightButton from '../models/LightButton';
import ButtonGroup from './ButtonGroup';
import AddButton from './AddButton';
import { controlMode } from '../constants';
import AppTextInput from '../inputs/AppTextInput';

const getModes = (lightModes) => {
  return [controlMode].concat(lightModes);
};

export default observer(({ lightSettings, lightModes, }) => {
  const [modes, setModes] = React.useState(lightModes);
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

  useEffect(() => {
    setModes(getModes(lightModes));
  }, [lightModes]);

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
            lightModes={modes}
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
